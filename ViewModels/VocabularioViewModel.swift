//
//  VocabularioViewModel.swift
//  MedCare
//
//  Created by Romi on 30/1/26.
//

import Foundation

final class VocabularioViewModel: ObservableObject {

    @Published var palabraActual: Vocabulario?
    @Published var cargando = false

    func cargarSiguientePalabra() {
        print("🌐 Llamando API vocabulario/siguiente")
        cargando = true

        VocabularioAPI.shared.obtenerSiguiente { palabra in
            DispatchQueue.main.async {
                self.cargando = false

                if let palabra = palabra {
                    print("✅ Palabra recibida:", palabra.palabra)
                    self.palabraActual = palabra
                } else {
                    print("⚠️ No se recibió vocabulario")
                    self.palabraActual = nil
                }
            }
        }
    }
/*
    func marcarActual() {
        guard let id = palabraActual?.id else { return }
        VocabularioAPI.shared.marcarVocabulario(id: id)
    }*/
    func marcarActual(completion: @escaping (Bool) -> Void) {

        guard let palabra = palabraActual else {
            print("⚠️ No hay palabra para marcar")
            completion(false)
            return
        }

        print("📌 Marcando palabra ID:", palabra.id)

        VocabularioAPI.shared.marcarVocabulario(vocabularioId: palabra.id) { ok in
            DispatchQueue.main.async {
                if ok {
                    print("✅ Palabra marcada correctamente")
                } else {
                    print("❌ No se pudo marcar la palabra")
                }
                completion(ok)
            }
        }
    }


}
