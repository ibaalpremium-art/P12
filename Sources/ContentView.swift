import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @State private var p12URL: URL? = nil
    @State private var oldPassword = ""
    @State private var newPassword = ""
    
    @State private var showFilePicker = false
    @State private var showShareSheet = false
    @State private var generatedP12URL: URL? = nil
    
    @State private var alertMessage = ""
    @State private var showAlert = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("1. Select Certificate")) {
                    Button(action: { showFilePicker = true }) {
                        HStack {
                            Image(systemName: "folder.fill")
                            Text(p12URL != nil ? p12URL!.lastPathComponent : "Choose .p12 file")
                        }
                    }
                }
                
                Section(header: Text("2. Credentials")) {
                    SecureField("Old Password: ••••••••", text: $oldPassword)
                    SecureField("New Password: ••••••••", text: $newPassword)
                }
                
                Section {
                    Button(action: changePassword) {
                        HStack {
                            Spacer()
                            Text("CHANGE PASSWORD")
                                .bold()
                                .foregroundColor(.white)
                            Spacer()
                        }
                    }
                    .listRowBackground(p12URL == nil || oldPassword.isEmpty || newPassword.isEmpty ? Color.gray : Color.blue)
                    .disabled(p12URL == nil || oldPassword.isEmpty || newPassword.isEmpty)
                }
                
                if generatedP12URL != nil {
                    Section {
                        Button(action: { showShareSheet = true }) {
                            HStack {
                                Spacer()
                                Image(systemName: "checkmark.circle.fill")
                                Text("✅ Done — Save/Share P12")
                                    .bold()
                                Spacer()
                            }
                        }
                        .listRowBackground(Color.green)
                        .foregroundColor(.white)
                    }
                }
            }
            .navigationTitle("P12 Changer")
            // Document Picker untuk memilih file .p12
            .fileImporter(isPresented: $showFilePicker, allowedContentTypes: [UTType(filenameExtension: "p12") ?? .data]) { result in
                switch result {
                case .success(let url):
                    if url.startAccessingSecurityScopedResource() {
                        self.p12URL = url
                    }
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                }
            }
            // Pop-up Share/Save file yang sudah jadi
            .sheet(isPresented: $showShareSheet) {
                if let url = generatedP12URL {
                    ShareSheet(activityItems: [url])
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Status"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    func changePassword() {
        guard let inputURL = p12URL else { return }
        
        do {
            // 1. Baca file .p12 asli
            let p12Data = try Data(contentsOf: inputURL)
            
            // 2. PROSES UBAH PASSWORD (Logic Placeholder)
            // Di sini kamu memasukkan logic library OpenSSL untuk men-decrypt p12Data menggunakan `oldPassword`, 
            // lalu meng-encrypt kembali menjadi PKCS12 dengan `newPassword`.
            // Untuk preview UI ini, kita asumsikan outputData adalah data p12 yang baru.
            let outputData = p12Data 
            
            // 3. Simpan file baru ke temporary directory agar bisa di-share
            let tempDir = FileManager.default.temporaryDirectory
            let newFileName = "New_\(inputURL.lastPathComponent)"
            let outputURL = tempDir.appendingPathComponent(newFileName)
            
            try outputData.write(to: outputURL)
            
            // 4. Update UI
            self.generatedP12URL = outputURL
            self.alertMessage = "Password successfully changed!\nReady to save."
            self.showAlert = true
            
        } catch {
            self.alertMessage = "Error processing file: \(error.localizedDescription)"
            self.showAlert = true
        }
    }
}

// Wrapper untuk memanggil iOS Share Sheet standard (Bisa Save to Files, Airdrop, dll)
struct ShareSheet: UIViewControllerRepresentable {
    var activityItems: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
