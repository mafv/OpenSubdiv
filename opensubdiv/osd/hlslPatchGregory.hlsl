//
//     Copyright (C) Pixar. All rights reserved.
//
//     This license governs use of the accompanying software. If you
//     use the software, you accept this license. If you do not accept
//     the license, do not use the software.
//
//     1. Definitions
//     The terms "reproduce," "reproduction," "derivative works," and
//     "distribution" have the same meaning here as under U.S.
//     copyright law.  A "contribution" is the original software, or
//     any additions or changes to the software.
//     A "contributor" is any person or entity that distributes its
//     contribution under this license.
//     "Licensed patents" are a contributor's patent claims that read
//     directly on its contribution.
//
//     2. Grant of Rights
//     (A) Copyright Grant- Subject to the terms of this license,
//     including the license conditions and limitations in section 3,
//     each contributor grants you a non-exclusive, worldwide,
//     royalty-free copyright license to reproduce its contribution,
//     prepare derivative works of its contribution, and distribute
//     its contribution or any derivative works that you create.
//     (B) Patent Grant- Subject to the terms of this license,
//     including the license conditions and limitations in section 3,
//     each contributor grants you a non-exclusive, worldwide,
//     royalty-free license under its licensed patents to make, have
//     made, use, sell, offer for sale, import, and/or otherwise
//     dispose of its contribution in the software or derivative works
//     of the contribution in the software.
//
//     3. Conditions and Limitations
//     (A) No Trademark License- This license does not grant you
//     rights to use any contributor's name, logo, or trademarks.
//     (B) If you bring a patent claim against any contributor over
//     patents that you claim are infringed by the software, your
//     patent license from such contributor to the software ends
//     automatically.
//     (C) If you distribute any portion of the software, you must
//     retain all copyright, patent, trademark, and attribution
//     notices that are present in the software.
//     (D) If you distribute any portion of the software in source
//     code form, you may do so only under this license by including a
//     complete copy of this license with your distribution. If you
//     distribute any portion of the software in compiled or object
//     code form, you may only do so under a license that complies
//     with this license.
//     (E) The software is licensed "as-is." You bear the risk of
//     using it. The contributors give no express warranties,
//     guarantees or conditions. You may have additional consumer
//     rights under your local laws which this license cannot change.
//     To the extent permitted under your local laws, the contributors
//     exclude the implied warranties of merchantability, fitness for
//     a particular purpose and non-infringement.
//

//----------------------------------------------------------
// Patches.Coefficients
//----------------------------------------------------------

#if OSD_MAX_VALENCE<=10
static float ef[7] = {
    0.813008, 0.500000, 0.363636, 0.287505,
    0.238692, 0.204549, 0.179211
};
#else
static float ef[27] = {
    0.812816, 0.500000, 0.363644, 0.287514,
    0.238688, 0.204544, 0.179229, 0.159657,
    0.144042, 0.131276, 0.120632, 0.111614,
    0.103872, 0.09715, 0.0912559, 0.0860444,
    0.0814022, 0.0772401, 0.0734867, 0.0700842,
    0.0669851, 0.0641504, 0.0615475, 0.0591488,
    0.0569311, 0.0548745, 0.0529621
};
#endif

float csf(uint n, uint j)
{
    if (j%2 == 0) {
        return cos((2.0 * M_PI * float(float(j-0)/2.0f))/(float(n)+3.0));
    } else {
        return sin((2.0 * M_PI * float(float(j-1)/2.0f))/(float(n)+3.0));
    }
}

//----------------------------------------------------------
// Patches.TessVertexGregory
//----------------------------------------------------------

Buffer<float> g_VertexBuffer : register( t0 );
Buffer<int> g_ValenceBuffer : register( t1 );

void vs_main_patches( in InputVertex input,
                      uint vID : SV_VertexID,
                      out GregHullVertex output )
{
     output.hullPosition = mul(ModelViewMatrix, input.position).xyz;
     OSD_PATCH_CULL_COMPUTE_CLIPFLAGS(input.position);

     uint valence = uint(g_ValenceBuffer[int(vID * (2 * OSD_MAX_VALENCE + 1))]);
     output.valence = int(valence);

     float3 f[OSD_MAX_VALENCE]; 
     float3 pos = input.position.xyz;
     float3 opos = float3(0,0,0);

     for (uint i=0; i<valence; ++i) {
        uint im=(i+valence-1)%valence; 
        uint ip=(i+1)%valence; 

        uint idx_neighbor = uint(g_ValenceBuffer[int(vID * (2*OSD_MAX_VALENCE+1) + 2*i + 0 + 1)]);

        float3 neighbor =
            float3(g_VertexBuffer[int(OSD_NUM_ELEMENTS*idx_neighbor)],
                   g_VertexBuffer[int(OSD_NUM_ELEMENTS*idx_neighbor+1)],
                   g_VertexBuffer[int(OSD_NUM_ELEMENTS*idx_neighbor+2)]);

        uint idx_diagonal = uint(g_ValenceBuffer[int(vID * (2*OSD_MAX_VALENCE+1) + 2*i + 1 + 1)]);

        float3 diagonal =
            float3(g_VertexBuffer[int(OSD_NUM_ELEMENTS*idx_diagonal)],
                   g_VertexBuffer[int(OSD_NUM_ELEMENTS*idx_diagonal+1)],
                   g_VertexBuffer[int(OSD_NUM_ELEMENTS*idx_diagonal+2)]);

        uint idx_neighbor_p = uint(g_ValenceBuffer[int(vID * (2*OSD_MAX_VALENCE+1) + 2*ip + 0 + 1)]);

        float3 neighbor_p =
            float3(g_VertexBuffer[int(OSD_NUM_ELEMENTS*idx_neighbor_p)],
                   g_VertexBuffer[int(OSD_NUM_ELEMENTS*idx_neighbor_p+1)],
                   g_VertexBuffer[int(OSD_NUM_ELEMENTS*idx_neighbor_p+2)]);

        uint idx_neighbor_m = uint(g_ValenceBuffer[int(vID * (2*OSD_MAX_VALENCE+1) + 2*im + 0 + 1)]);

        float3 neighbor_m =
            float3(g_VertexBuffer[int(OSD_NUM_ELEMENTS*idx_neighbor_m)],
                   g_VertexBuffer[int(OSD_NUM_ELEMENTS*idx_neighbor_m+1)],
                   g_VertexBuffer[int(OSD_NUM_ELEMENTS*idx_neighbor_m+2)]);

        uint idx_diagonal_m = uint(g_ValenceBuffer[int(vID * (2*OSD_MAX_VALENCE+1) + 2*im + 1 + 1)]);

        float3 diagonal_m =
            float3(g_VertexBuffer[int(OSD_NUM_ELEMENTS*idx_diagonal_m)],
                   g_VertexBuffer[int(OSD_NUM_ELEMENTS*idx_diagonal_m+1)],
                   g_VertexBuffer[int(OSD_NUM_ELEMENTS*idx_diagonal_m+2)]);

        f[i] = (pos * float(valence) + (neighbor_p + neighbor)*2.0 + diagonal) / (float(valence)+5.0);

        opos += f[i];
        output.r[i] = (neighbor_p-neighbor_m)/3.0 + (diagonal - diagonal_m)/6.0;
    }

    opos /= valence;
    output.position = float4(opos, 1.0f).xyz;

#if OSD_NUM_VARYINGS > 0
    for (int i = 0; i< OSD_NUM_VARYINGS; ++i)
        output.varyings[i] = input.varyings[i];
#endif

    float3 e;
    output.e0 = float3(0,0,0);
    output.e1 = float3(0,0,0);
    for(uint i=0; i<valence; ++i) {
        uint im = (i + valence -1) % valence;
        e = 0.5 * (f[i] + f[im]);
        output.e0 += csf(valence-3, 2*i) *e;
        output.e1 += csf(valence-3, 2*i + 1)*e;
    }
    output.e0 *= ef[valence - 3];
    output.e1 *= ef[valence - 3];
}

//----------------------------------------------------------
// Patches.HullGregory
//----------------------------------------------------------

Buffer<int> g_QuadOffsetBuffer : register( t2 );

HS_CONSTANT_FUNC_OUT HSConstFunc(
    InputPatch<GregHullVertex, 4> patch,
    uint primitiveID : SV_PrimitiveID)
{
    HS_CONSTANT_FUNC_OUT output;
    int patchLevel = GetPatchLevel(primitiveID);

    OSD_PATCH_CULL(4);

#if OSD_ENABLE_SCREENSPACE_TESSELLATION
    output.tessLevelOuter[0] =
        TessAdaptive(patch[0].hullPosition.xyz, patch[1].hullPosition.xyz, patchLevel);
    output.tessLevelOuter[1] =
        TessAdaptive(patch[0].hullPosition.xyz, patch[3].hullPosition.xyz, patchLevel);
    output.tessLevelOuter[2] =
        TessAdaptive(patch[2].hullPosition.xyz, patch[3].hullPosition.xyz, patchLevel);
    output.tessLevelOuter[3] =
        TessAdaptive(patch[1].hullPosition.xyz, patch[2].hullPosition.xyz, patchLevel);
    output.tessLevelInner[0] =
        max(output.tessLevelOuter[1], output.tessLevelOuter[3]);
    output.tessLevelInner[1] =
        max(output.tessLevelOuter[0], output.tessLevelOuter[2]);
#else
    output.tessLevelInner[0] = GetTessLevel(patchLevel);
    output.tessLevelInner[1] = GetTessLevel(patchLevel);
    output.tessLevelOuter[0] = GetTessLevel(patchLevel);
    output.tessLevelOuter[1] = GetTessLevel(patchLevel);
    output.tessLevelOuter[2] = GetTessLevel(patchLevel);
    output.tessLevelOuter[3] = GetTessLevel(patchLevel);
#endif
    return output;
}

[domain("quad")]
[partitioning("integer")]
[outputtopology("triangle_ccw")]
[outputcontrolpoints(4)]
[patchconstantfunc("HSConstFunc")]
GregDomainVertex hs_main_patches(
    in InputPatch<GregHullVertex, 4> patch,
    uint primitiveID : SV_PrimitiveID,
    in uint ID : SV_OutputControlPointID )
{
    uint i = ID;
    uint ip = (i+1)%4;
    uint im = (i+3)%4;
    uint n = uint(patch[i].valence);
    int base = GregoryQuadOffsetBase;

    GregDomainVertex output;
    output.position = patch[ID].position;

    uint start = g_QuadOffsetBuffer[int(4*(primitiveID+base) + i)] & 0x00ff;
    uint prev = uint(g_QuadOffsetBuffer[int(4*(primitiveID+base) + i)]) & 0xff00;
    prev=uint(prev/256);

    // Control Vertices based on : 
    // "Approximating Subdivision Surfaces with Gregory Patches for Hardware Tessellation" 
    // Loop, Schaefer, Ni, Castafio (ACM ToG Siggraph Asia 2009)
    //
    //  P3         e3-      e2+         E2
    //     O--------O--------O--------O
    //     |        |        |        |
    //     |        |        |        |
    //     |        | f3-    | f2+    |
    //     |        O        O        |
    // e3+ O------O            O------O e2-
    //     |     f3+          f2-     |
    //     |                          |
    //     |                          |
    //     |      f0-         f1+     |
    // e0- O------O            O------O e1+
    //     |        O        O        |
    //     |        | f0+    | f1-    |
    //     |        |        |        |
    //     |        |        |        |
    //     O--------O--------O--------O
    //  P0         e0+      e1-         E1
    //

    float3 Ep = patch[i].position + patch[i].e0 * csf(n-3, 2*start) + patch[i].e1*csf(n-3, 2*start +1);
    float3 Em = patch[i].position + patch[i].e0 * csf(n-3, 2*prev ) + patch[i].e1*csf(n-3, 2*prev + 1);

    uint np = patch[ip].valence;
    uint nm = patch[im].valence;

    uint prev_p = uint(g_QuadOffsetBuffer[int(4*(primitiveID+base) + ip)])&0xff00;
    prev_p=uint(prev_p/256);
    float3 Em_ip = patch[ip].position + patch[ip].e0*csf(np-3,2*prev_p) +patch[ip].e1*csf(np-3, 2*prev_p+1);

    uint start_m = g_QuadOffsetBuffer[int(4*(primitiveID+base) + im)]&0x00ff;
    float3 Ep_im = patch[im].position + patch[im].e0*csf(nm-3, 2*start_m) + patch[im].e1*csf(nm-3, 2*start_m+1);

    float s1 = 3 - 2*csf(n-3,2)-csf(np-3,2);
    float s2 = 2*csf(n-3,2);

    float3 Fp = (csf(np-3,2)*patch[i].position + s1*Ep + s2*Em_ip + patch[i].r[start])/3.0;

    s1 = 3.0 -2.0*cos(2.0*M_PI/float(n)) - cos(2*M_PI/float(nm));
    float3 Fm = (csf(nm-3,2)*patch[i].position + s1*Em +s2*Ep_im - patch[i].r[prev])/3.0;

    output.Ep = Ep;
    output.Em = Em;
    output.Fp = Fp;
    output.Fm = Fm;

    int patchLevel = GetPatchLevel(primitiveID);
    output.patchCoord = float4(0, 0,
                               patchLevel+0.5,
                               primitiveID+LevelBase+0.5);

    OSD_COMPUTE_PTEX_COORD_HULL_SHADER;

    return output;
}

//----------------------------------------------------------
// Patches.DomainGregory
//----------------------------------------------------------

void Univar4(in float u, out float B[4], out float D[4])
{
    float t = u;
    float s = 1.0 - u;

    float A0 =     s * s;
    float A1 = 2 * s * t;
    float A2 = t * t;

    B[0] =          s * A0;
    B[1] = t * A0 + s * A1;
    B[2] = t * A1 + s * A2;
    B[3] = t * A2;

    D[0] =    - A0;
    D[1] = A0 - A1;
    D[2] = A1 - A2;
    D[3] = A2;
}

[domain("quad")]
void ds_main_patches(
    in HS_CONSTANT_FUNC_OUT input,
    in OutputPatch<GregDomainVertex, 4> patch,
    in float2 uv : SV_DomainLocation,
    out OutputVertex output )
{
    float u = uv.x,
          v = uv.y;

    float3 p[20];

    p[0] = patch[0].position;
    p[1] = patch[0].Ep;
    p[2] = patch[0].Em;
    p[3] = patch[0].Fp;
    p[4] = patch[0].Fm;

    p[5] = patch[1].position;
    p[6] = patch[1].Ep;
    p[7] = patch[1].Em;
    p[8] = patch[1].Fp;
    p[9] = patch[1].Fm;

    p[10] = patch[2].position;
    p[11] = patch[2].Ep;
    p[12] = patch[2].Em;
    p[13] = patch[2].Fp;
    p[14] = patch[2].Fm;

    p[15] = patch[3].position;
    p[16] = patch[3].Ep;
    p[17] = patch[3].Em;
    p[18] = patch[3].Fp;
    p[19] = patch[3].Fm;

    float3 q[16];

    float U = 1-u, V=1-v;

    float d11 = u+v; if(u+v==0.0f) d11 = 1.0f;
    float d12 = U+v; if(U+v==0.0f) d12 = 1.0f;
    float d21 = u+V; if(u+V==0.0f) d21 = 1.0f;
    float d22 = U+V; if(U+V==0.0f) d22 = 1.0f;

    q[ 5] = (u*p[3] + v*p[4])/d11;
    q[ 6] = (U*p[9] + v*p[8])/d12;
    q[ 9] = (u*p[19] + V*p[18])/d21;
    q[10] = (U*p[13] + V*p[14])/d22;

    q[ 0] = p[0];
    q[ 1] = p[1];
    q[ 2] = p[7];
    q[ 3] = p[5];
    q[ 4] = p[2];
    q[ 7] = p[6];
    q[ 8] = p[16];
    q[11] = p[12];
    q[12] = p[15];
    q[13] = p[17];
    q[14] = p[11];
    q[15] = p[10];

    float B[4], D[4];

    Univar4(uv.x, B, D);
    float3 BUCP[4], DUCP[4];

    for (int i=0; i<4; ++i) {
        BUCP[i] =  float3(0, 0, 0);
        DUCP[i] =  float3(0, 0, 0);

        for (uint j=0; j<4; ++j) {
            // reverse face front
            float3 A = q[i + 4*j];

            BUCP[i] += A * B[j];
            DUCP[i] += A * D[j];
        }
    }

    float3 WorldPos  = float3(0, 0, 0);
    float3 Tangent   = float3(0, 0, 0);
    float3 BiTangent = float3(0, 0, 0);

    Univar4(uv.y, B, D);

    for (uint i=0; i<4; ++i) {
        WorldPos  += B[i] * BUCP[i];
        Tangent   += B[i] * DUCP[i];
        BiTangent += D[i] * BUCP[i];
    }

    BiTangent = mul(ModelViewMatrix, float4(BiTangent, 0)).xyz;
    Tangent = mul(ModelViewMatrix, float4(Tangent, 0)).xyz;

    float3 normal = normalize(cross(BiTangent, Tangent));

    output.position = mul(ModelViewMatrix, float4(WorldPos, 1.0));
    output.normal = normal;
    output.tangent = normalize(BiTangent);

    output.patchCoord = patch[0].patchCoord;
    output.patchCoord.xy = float2(v, u);

    OSD_COMPUTE_PTEX_COORD_DOMAIN_SHADER;

    OSD_DISPLACEMENT_CALLBACK;

    output.positionOut = mul(ModelViewProjectionMatrix, float4(WorldPos, 1.0f));
}

//----------------------------------------------------------
// Patches.Vertex
//----------------------------------------------------------

void vs_main( in InputVertex input,
              out OutputVertex output)
{
    output.positionOut = mul(ModelViewProjectionMatrix, input.position);
}

//----------------------------------------------------------
// Patches.PixelColor
//----------------------------------------------------------

cbuffer Data : register( b2 ) {
    float4 color;
};

void ps_main( in OutputVertex input,
              out float4 colorOut : SV_Target )
{
    colorOut = color;
}
