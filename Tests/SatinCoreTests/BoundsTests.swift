//
//  BoundsTests.swift
//  
//
//  Created by Taylor Holliday on 8/3/22.
//

import XCTest
import SatinCore
import simd

extension Bounds: Equatable {
    public static func == (lhs: Bounds, rhs: Bounds) -> Bool {
        return simd_equal(lhs.min, rhs.min) && simd_equal(lhs.max, rhs.max)
    }
}

class BoundsTests: XCTestCase {

    func testComputeBoundsFromVertices() {

        var vertices0: [Vertex] = []
        XCTAssertEqual(computeBoundsFromVertices(&vertices0, 0), Bounds(min: .init(0,0,0), max: .init(0,0,0)))

        var vertices1 = [
            Vertex(position: .init(0, 0, 0, 1), normal: .init(0, 0, 0), uv: .init(0, 0))
        ]
        XCTAssertEqual(computeBoundsFromVertices(&vertices1, 1), Bounds(min: .init(0,0,0), max: .init(0,0,0)))

        var vertices2 = [
            Vertex(position: .init(0, 0, 0, 1), normal: .init(0, 0, 0), uv: .init(0, 0)),
            Vertex(position: .init(1, 0, 0, 1), normal: .init(0, 0, 0), uv: .init(0, 0))
        ]
        XCTAssertEqual(computeBoundsFromVertices(&vertices2, 2), Bounds(min: .init(0,0,0), max: .init(1,0,0)))

        var vertices3 = [
            Vertex(position: .init(0, 0, 0, 1), normal: .init(0, 0, 0), uv: .init(0, 0)),
            Vertex(position: .init(1, 0, 0, 1), normal: .init(0, 0, 0), uv: .init(0, 0)),
            Vertex(position: .init(0, 1, 0, 1), normal: .init(0, 0, 0), uv: .init(0, 0)),
            Vertex(position: .init(0, 0, 1, 1), normal: .init(0, 0, 0), uv: .init(0, 0)),
        ]
        XCTAssertEqual(computeBoundsFromVertices(&vertices3, 4), Bounds(min: .init(0,0,0), max: .init(1,1,1)))
        
    }
}
