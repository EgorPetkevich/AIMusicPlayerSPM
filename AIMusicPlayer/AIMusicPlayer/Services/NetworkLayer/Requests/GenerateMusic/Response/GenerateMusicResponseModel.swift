//
//  GenerateMusicResponse.swift
//  AIMusicPlayer
//
//  Created by George Popkich on 22.12.25.
//

import Foundation

///{
///  "code": 200,
///  "msg": "All generated successfully.",
///  "data": {
///    "taskId": "2fac****9f72"
///  }
///}

struct GenerateMusicResponseModel: Decodable {
    struct DataBlock: Decodable {
        let taskId: String
    }

    let code: Int
    let msg: String
    let data: DataBlock
}
