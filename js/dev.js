window.THREE = require('three');
THREE.EffectComposer = require('three-effectcomposer')(THREE);
const createOrbitViewer = require('three-orbit-viewer')(THREE);

const glslify = require('glslify');

const to = require('./to.js')

class Dev {

    videoFactory(src) {
        var video = document.createElement('video');
        video.width = 100;
        video.loop = true;

        video.muted = true;
        video.src = src;
        video.setAttribute('webkit-playsinline', 'webkit-playsinline');
        video.playbackRate = 1.0;
        video.play();
        video.setAttribute('controls', true);

        video.className = "video";
        document.body.appendChild(video);
        return video;
    }

    setupVideo(cb) {
        var v1 = this.videoFactory('./assets/v10.mp4');
        var v2 = this.videoFactory('./assets/a.mp4');
        var loadedCt = 0;

        var loadedCB = function() {
            this.vWidth = v1.videoWidth;
            this.vHeight = v1.videoHeight;
            loadedCt++;
            if (loadedCt >= 2) cb(v1, v2)
        }.bind(this)

        v1.addEventListener("loadeddata", loadedCB(), false);
        v2.addEventListener("loadeddata", loadedCB(), false);
    }



    constructor() {
        this.clock = new THREE.Clock();

        let x = window.innerWidth;
        let y = window.innerHeight;

        this.camera = new THREE.OrthographicCamera(x / -2, x / 2, y / 2, y / -2, 1, 1000);
        //this.camera = new THREE.PerspectiveCamera(45, window.innerWidth / window.innerHeight, 1, 1000);
        this.camera.position.set(0, 0, 700);

        this.scene = new THREE.Scene();



        const c = document.querySelector('canvas');
        this.renderer = new THREE.WebGLRenderer({
            'canvas': c
        });
        this.renderer.domElement.className = 'sky';

        this.renderer.setPixelRatio(1.0);
        this.renderer.setFaceCulling(THREE.CullFaceNone);

        /* window.onmousemove = (function(e){
             if (this.uniforms &&  this.uniforms.iPos) {
                 this.uniforms.iPos.value.x = e.clientX*2.0;
                 this.uniforms.iPos.value.y = window.innerHeight*2.0 - e.clientY*2.0;
             }
         }).bind(this);*/


        //var tx = new THREE.TextureLoader().load( 'assets/tex_01.jpg' );
        // var tx2 = new THREE.TextureLoader().load( 'assets/tex_02.jpg' );
        //this.setupVideo(function(videoA, videoB) {
        x = window.innerWidth;
        y = window.innerHeight;
        this.renderer.setSize(x, y);
        /*
                    var texture = new THREE.VideoTexture(videoA);
                    texture.minFilter = THREE.NearestFilter;
                    texture.magFilter = THREE.NearestFilter;
                    texture.format = THREE.RGBFormat;

                    var textureB = new THREE.VideoTexture(videoB);
                    textureB.minFilter = THREE.NearestFilter;
                    textureB.magFilter = THREE.NearestFilter;
                    textureB.format = THREE.RGBFormat;*/

        var textureC = new THREE.TextureLoader().load("assets/graynoise.png");
        textureC.wrapS = THREE.RepeatWrapping;
        textureC.wrapT = THREE.RepeatWrapping;
        //texture.repeat.set( 4, 4 );


        this.uniforms = {
            iTime: {
                type: "f",
                value: 0.1
            }, //240
            iResolution: {
                type: "v2",
                value: new THREE.Vector2(x, y)
            },
            iChannel0: null,
            iChannel1: null,
            iChannel2: {
                type: "t",
                value: textureC
            },
            iChannel3: null,
            iCli: {
                type: "f",
                value: 0.1
            },
            iPos: {
                type: "v2",
                value: new THREE.Vector2(0, 0)
            },
        };

        var matP = new THREE.ShaderMaterial({
            uniforms: this.uniforms,
            depthTest: false,
            vertexShader: glslify.file('./head.glsl') + '\n' + glslify.file('./vs.glsl'),
            fragmentShader: glslify.file('./head.glsl') + '\n' + glslify.file('./stars.glsl'),
            side: THREE.DoubleSide

        });

        var geoP = new THREE.PlaneBufferGeometry(x * 2, y * 2, 1, 1);
        var mshP = new THREE.Mesh(geoP, matP);
        this.scene.add(mshP);

        var loader = new THREE.TextureLoader();
        loader.load('../assets/trees3.jpg', function(texture) {

            texture.wrapS = THREE.RepeatWrapping;
            //texture.magFilter =  THREE.NearestFilter;
            texture.minFilter = THREE.NearestFilter;
            texture.wrapT = THREE.ClampToEdgeWrapping;
            var geometry = new THREE.PlaneBufferGeometry(x, y, 1, 1);
            var material = new THREE.MeshBasicMaterial({
                map: texture,
                overdraw: false,
                blending: THREE.SubtractiveBlending,
                depthTest: true,
                transparent: true
            });

            var mesh = new THREE.Mesh(geometry, material);
            mesh.position.set(0, y / -2 + geometry.parameters.height / 2, 0);


            this.scene.add(mesh);


        }.bind(this));




        this.playing = true;
        //}.bind(this));


        document.body.style.margin = '0';
        document.body.style.overflow = 'hidden';
        //        const gl = require('./safe-webgl2-context')(canvas);

        this.composer = new THREE.EffectComposer(this.renderer);

        var rp = new THREE.EffectComposer.RenderPass(this.scene, this.camera);
        rp.renderToScreen = true;
        this.composer.addPass(rp);


        window.addEventListener('resize', this.onWindowResize.bind(this), false);

        this.animate();
    }

    animate() {
        requestAnimationFrame(this.animate.bind(this));
        this.render();
    }

    render() {
        if (!this.playing) return;


        this.uniforms.iTime.value += this.clock.getDelta();
        this.uniforms.iTime.needsUpdate = true;
        //this.composer.render(this.scene, this.camera);
        this.renderer.render(this.scene, this.camera);

    }

    onWindowResize() {

        this.camera.aspect = window.innerWidth / window.innerHeight;
        this.camera.updateProjectionMatrix();
        this.renderer.setSize(window.innerWidth, window.innerHeight);
    }

}

window.dev = new Dev();