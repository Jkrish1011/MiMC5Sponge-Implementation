pragma circom 2.0.0;

template MiMC5Feistal() {
    signal input iL;
    signal input iR;
    signal input k;

    signal output oL;
    signal output oR;

    // Because Feistal encodes only half the input array. thus douling the rounds.
    var nRounds = 20;
    var c[20] = [
        0,
        21469745217645236226405533686231592324177671190346326883245530828568381403876,
        81888242871839275222246405745257275088548364400416034343698204186575808495612,
        91888242871839275222246405745257275088548364400416034343698204186575808495613,
        11888242871839275222246405745257275088548364400416034343698204186575808495614,
        31888242871839275222246405745257275088548369400416034343698204186575808495615,
        21888242871839275222249005745257275088548364400416034343698204186575808495616,
        51888242871839275222246405745257275088548364400416034343698204186575808495617,
        61888242871839275222246405745257275088548364400416034343698204186575808495618,
        71888242871839275222246405745257275088548364400416034343698204186575808495619,
        21469745217645236226405533686211592324177671190346326883245530828568381403876,
        21469745217645236226405533686221592324177671190346326883245530828568381403876,
        81888242871839275222246405745237275088548364400416034343698204186575808495612,
        91888242871839275222246405745247275088548364400416034343698204186575808495613,
        11888242871839275222246405745267275088548364400416034343698204186575808495614,
        31888242871839275222246405745277275088548369400416034343698204186575808495615,
        21888242871839275222249005745287275088548364400416034343698204186575808495616,
        51888242871839275222246405745297275088548364400416034343698204186575808495617,
        61888242871839275222246405715257275088548364400416034343698204186575808495618,
        71888242871839275222246405725257275088548364400416034343698204186575808495619
    ];

    signal lastOutputL[nRounds + 1];
    signal lastOutputR[nRounds + 1];

    var base[nRounds];
    signal base2[nRounds];
    signal base4[nRounds];

    lastOutputL[0] <== iL;
    lastOutputR[0] <== iR;

    for(var i=0; i < nRounds; i++){
        base[i] = lastOutputR[i] + k + c[i];
        base2[i] <== base[i] * base[i];
        base4[i] <== base2[i] * base2[i];

        lastOutputR[i + 1] <== lastOutputL[i] + base4[i] * base[i];
        lastOutputL[i + 1] <== lastOutputR[i];
    }

    oL <== lastOutputL[nRounds];
    oR <== lastOutputR[nRounds];
}

template MiMC5Sponge(nInputs) {
    signal input k;
    signal input ins[nInputs];
    signal output o;

    signal lastR[nInputs + 1];
    signal lastC[nInputs + 1];

    lastR[0] <== 0;
    lastC[0] <== 0;

    component layers[nInputs];

    for(var i=0; i < nInputs; i++){
        layers[i] = MiMC5Feistal();

        layers[i].iL <== lastR[i] + ins[i];
        layers[i].iR <== lastC[i];
        layers[i].k <== k;

        lastR[i + 1] <== layers[i].oL;
        lastC[i + 1] <== layers[i].oR;
    }

    o <== lastR[nInputs];
}

component main = MiMC5Sponge(2);