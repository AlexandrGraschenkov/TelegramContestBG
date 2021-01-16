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
    float2 size;
};

struct Metaball {
    float2 xy;
    float3 color;
    float3 temp;
};



vertex float4 metaball_vertex(uint vid [[vertex_id]])
{
    float4x4 vert = float4x4(float4( -1.0, -1.0, 0.0, 1.0 ),
                             float4(  1.0, -1.0, 0.0, 1.0 ),
                             float4( -1.0,  1.0, 0.0, 1.0 ),
                             float4(  1.0,  1.0, 0.0, 1.0 ));
    return vert[vid];
}

float metaDist(float2 a, float2 b) {
    return exp((1 - distance(a, b)) * 5 - 3);
}

fragment float4 metaball_fragment(float4 pos[[position]],
                                  constant Metaball *points[[buffer(0)]],
                                  constant GlobalParameters& params[[buffer(1)]])
{
    float x = pos.x / params.size.x;
    float y = pos.y / params.size.y;
    
    // softmax
    float distSum = 0;
    for (uint i = 0; i < params.metaballCount; i++) {
        float dist = metaDist(points[i].xy, float2(x, y));
        distSum += dist;
    }
    
    float3 finalColor = {0, 0, 0};
    for (uint i = 0; i < params.metaballCount; i++) {
        float dist = metaDist(points[i].xy, float2(x, y));
        dist /= distSum;
        finalColor += points[i].color * dist;
    }
    
//    float dist = distance(points[0].xy, float2(x, y));
//    return float4(dist * points[2].color, 1);
    
    return float4(finalColor, 1);
}

