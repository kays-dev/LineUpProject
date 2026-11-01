// Formulaire de connexion factice pour tester la connexion API

import SwiftUI

struct TemporaryLoginView: View {

    @Environment(SessionStore.self) private var sessionStore
    @Environment(WorkshopStore.self) private var workshopStore
    @Environment(CategoryStore.self) private var categoryStore

    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String?
    @State private var isLoading = false
    @State private var filtersViewModel: WorkshopFiltersViewModel?

    var body: some View {
        Group {
            if sessionStore.isRestoring {
                ProgressView("Vérification de la session...")

            } else if sessionStore.isLoggedIn,
                      let viewModel = filtersViewModel {

                WorkshopFilterScreen(
                    viewModel: viewModel,
                    dates: viewModel.availableDays,
                    categories: categoryStore.categories.map { $0.name }
                )

            } else {
                loginForm
            }
        }
        .task {
            await sessionStore.restoreSession()

            if sessionStore.isLoggedIn {
                await loadFilters()
            }
        }
    }

    private var loginForm: some View {
        VStack(spacing: 20) {
            Text("Connexion temporaire")
                .font(.title2.bold())

            TextField("Adresse email", text: $email)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
                .autocorrectionDisabled()
                .textFieldStyle(.roundedBorder)

            SecureField("Mot de passe", text: $password)
                .textFieldStyle(.roundedBorder)

            if let errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
            }

            Button {
                Task {
                    await login()
                }
            } label: {
                if isLoading {
                    ProgressView()
                } else {
                    Text("Se connecter")
                }
            }
            .disabled(email.isEmpty || password.isEmpty || isLoading)
        }
        .padding(24)
    }

    @MainActor
    private func login() async {
        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            try await sessionStore.login(
                email: email,
                password: password
            )

            await loadFilters()

        } catch {
            errorMessage = "Connexion impossible : \(error.localizedDescription)"
        }
    }

    @MainActor
    private func loadFilters() async {
        do {
            let viewModel = WorkshopFiltersViewModel(
                workshopStore: workshopStore
            )

            try await viewModel.fetchWorkshopsDays()
            try await categoryStore.fetchAll()

            filtersViewModel = viewModel

        } catch {
            errorMessage = "Erreur de chargement : \(error.localizedDescription)"
        }
    }
}
