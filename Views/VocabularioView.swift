//
//  VocabularioView.swift
//  MedCare
//
//  Created by Romi on 30/1/26.
//

import SwiftUI

struct VocabularioView: View {

    @StateObject private var viewModel = VocabularioViewModel()
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        VStack(spacing: 20) {

            if viewModel.cargando {
                ProgressView("Cargando palabra...")
            }
            else if let v = viewModel.palabraActual {

                Text(v.palabra)
                    .font(.largeTitle)
                    .bold()

                Text(v.traduccion)
                    .font(.title2)
                    .foregroundColor(.secondary)

                Text(v.definicion)
                    .padding(.top, 8)

                Text("📝 \(v.oracion)")
                    .italic()
                    .padding(.top, 6)

                Button("Marcar como vista") {
                    viewModel.marcarActual { ok in
                        if ok {
                            dismiss() // 👈 vuelve a HomeView
                        }
                    }
                }
                .padding(.top, 16)

            } else {
                // 👇 ESTO evita la pantalla blanca
                Text("No hay vocabulario disponible")
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .onAppear {
            print("📘 VocabularioView apareció, cargando palabra")
            viewModel.cargarSiguientePalabra()
        }
    }
}

