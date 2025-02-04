//
//  Renderer.swift
//  Cubemap
//
//  Created by Reza Ali on 6/7/20.
//  Copyright © 2020 Hi-Rez. All rights reserved.
//
//  Cube Map Texture from: https://hdrihaven.com/hdri/
//

import Metal
import MetalKit

import Forge
import Satin

class PBRRenderer: BaseRenderer {
    // MARK: - 3D Scene
    class CustomShader: PBRShader {}

    class CustomMaterial: StandardMaterial {
        var pipelineURL: URL
        required init(pipelinesURL: URL) {
            pipelineURL = pipelinesURL.appendingPathComponent("Custom").appendingPathComponent("Shaders.metal")
            super.init(baseColor: .one, metallic: .zero, roughness: .zero)
        }

        required init() {
            fatalError("init() has not been implemented")
        }

        required init(from _: Decoder) throws {
            fatalError("init(from:) has not been implemented")
        }

        override func createShader() -> Shader {
            return CustomShader(label, pipelineURL)
        }
    }

    override var texturesURL: URL { sharedAssetsURL.appendingPathComponent("Textures") }

    lazy var scene = Scene("Scene", [mesh, skybox])
    lazy var context = Context(device, sampleCount, colorPixelFormat, depthPixelFormat, stencilPixelFormat)
    lazy var camera = PerspectiveCamera(position: [0.0, 0.0, 40.0], near: 0.001, far: 1000.0)
    lazy var cameraController = PerspectiveCameraController(camera: camera, view: mtkView)
    lazy var renderer: Satin.Renderer = .init(context: context)

    lazy var customMaterial: CustomMaterial = {
        let mat = CustomMaterial(pipelinesURL: pipelinesURL)
        mat.lighting = true
        mat.set("Base Color", [1.0, 1.0, 1.0, 1.0])
        mat.set("Emissive Color", [0.0, 0.0, 0.0, 0.0])
        return mat
    }()

    lazy var mesh: InstancedMesh = {
        let mesh = InstancedMesh(geometry: IcoSphereGeometry(radius: 0.875, res: 4), material: customMaterial, count: 11 * 11)
        mesh.label = "Spheres"
        let placer = Object()
        for y in 0 ..< 11 {
            for x in 0 ..< 11 {
                let index = y * 11 + x
                placer.position = simd_make_float3(2.0 * Float(x) - 10, 2.0 * Float(y) - 10, 0.0)
                mesh.setMatrixAt(index: index, matrix: placer.localMatrix)
            }
        }
        return mesh
    }()

    lazy var skybox = Mesh(geometry: SkyboxGeometry(size: 50), material: SkyboxMaterial())

    override func setupMtkView(_ metalKitView: MTKView) {
        metalKitView.sampleCount = 1
        metalKitView.depthStencilPixelFormat = .depth32Float
        metalKitView.preferredFramesPerSecond = 60
        metalKitView.colorPixelFormat = .bgra8Unorm
    }

    override func setup() {
        loadHdri()
        setupLights()
    }

    deinit {
        cameraController.disable()
    }

    func setupLights() {
        let dist: Float = 12.0
        let positions = [
            simd_make_float3(dist, dist, dist),
            simd_make_float3(-dist, dist, dist),
            simd_make_float3(dist, -dist, dist),
            simd_make_float3(-dist, -dist, dist),
        ]

        let sphereLightGeo = mesh.geometry
        let sphereLightMat = BasicColorMaterial(.one, .disabled)
        for (index, position) in positions.enumerated() {
            let light = PointLight(color: .one, intensity: 250, radius: 150.0)
            light.position = position
            let lightMesh = Mesh(geometry: sphereLightGeo, material: sphereLightMat)
            lightMesh.scale = .init(repeating: 0.25)
            lightMesh.label = "Light Mesh \(index)"
            light.add(lightMesh)

            scene.add(light)
        }
    }

    func loadHdri() {
        let filename = "brown_photostudio_02_2k.hdr"
        if let hdr = loadHDR(device: device, url: texturesURL.appendingPathComponent(filename)) {
            scene.setEnvironment(texture: hdr)
        }
    }

    override func update() {
        cameraController.update()
    }

    override func draw(_ view: MTKView, _ commandBuffer: MTLCommandBuffer) {
        guard let renderPassDescriptor = view.currentRenderPassDescriptor else { return }
        renderer.draw(
            renderPassDescriptor: renderPassDescriptor,
            commandBuffer: commandBuffer,
            scene: scene,
            camera: camera
        )
    }

    override func resize(_ size: (width: Float, height: Float)) {
        camera.aspect = size.width / size.height
        renderer.resize(size)
    }
}
