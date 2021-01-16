//
//  Metaball.metal
//  TelegramContestBG
//
//  Created by Alexander Graschenkov on 16.01.2021.
//

#include <metal_stdlib>
using namespace metal;


struct GlobalParameters {
    uint metaballCount;
};

struct Metaball {
    float2 xy;
    float3 color;
};



vertex float4 metaball_vertex(uint vid [[vertex_id]])
{
    float4x4 vert = float4x4(float4( -1.0, -1.0, 0.0, 1.0 ),
                             float4(  1.0, -1.0, 0.0, 1.0 ),
                             float4( -1.0,  1.0, 0.0, 1.0 ),
                             float4(  1.0,  1.0, 0.0, 1.0 ));
    return vert[vid];
}

fragment float4 metaball_fragment(float4 pos[[position]])
//                                  constant Metaball *points[[buffer(0)]],
//                                  constant GlobalParameters& globalParams[[buffer(1)]])
{
    return float4(pos.x, 0, 0, 1);
}

