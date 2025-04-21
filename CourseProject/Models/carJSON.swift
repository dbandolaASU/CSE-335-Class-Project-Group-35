//
//  carJSON.swift
//  CourseProject
//
//  Created by Jake Mulera on 4/18/25.
//

import Foundation
import SwiftUI

//Car struct to take in all the api car info
struct CarSpec: Decodable, Equatable {
    let make: String
    let model: String
    let year: Int
    let cylinders: Int?
    let drive: String?
    let fuel_type: String?
    let transmission: String?
    let displacement: Double?
}

//class to handle api call for and json that is returned
class CarJSONVM: ObservableObject {
    func getCarData(make: String, model: String, onSuccess: @escaping (CarSpec) -> Void) {
        let encodedMake = make.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "" //encode to send to api
        let encodedModel = model.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""

        let urlAsString = "https://api.api-ninjas.com/v1/cars?make=\(encodedMake)&model=\(encodedModel)" //craft url to make api call
        guard let url = URL(string: urlAsString) else { return }

        var request = URLRequest(url: url)
        request.setValue("bKAerH5KtY1E9ihBZqq74w==EjyRdpPNnvg2IesQ", forHTTPHeaderField: "X-Api-Key") //My api key for this api

        let jsonQuery = URLSession.shared.dataTask(with: request) { data, response, error in //Send api request
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }

            guard let data = data else { return }

            do {
                let decoded = try JSONDecoder().decode([CarSpec].self, from: data)
                if let car = decoded.first {
                    DispatchQueue.main.async {
                        onSuccess(car)
                    }
                }
            } catch {
                print("Decoding error: \(error)")
            }
        }

        jsonQuery.resume()
    }
}
