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
    float scale;
    float gradient;
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

float metaDist(float2 a, float2 b, float yScale, float gradient) {
    a.y *= yScale;
    b.y *= yScale;
//    float d = distance(a, b);
//    d = pow(d, 2);
    float d = pow(a.x-b.x, 2) + pow(a.y-b.y, 2);
    return exp((0.5 - d) * gradient);
}

float4 calculate_metaball_color(float x, float y, constant Metaball *points,
                                constant GlobalParameters& params) {
    float distSum = 0;
    float yScale = params.size.y / params.size.x;
    for (uint i = 0; i < params.metaballCount; i++) {
        float dist = metaDist(points[i].xy, float2(x, y), yScale, params.gradient);
        distSum += dist;
    }
    
    float3 finalColor = {0, 0, 0};
    for (uint i = 0; i < params.metaballCount; i++) {
        float dist = metaDist(points[i].xy, float2(x, y), yScale, params.gradient);
        dist /= distSum;
        finalColor += points[i].color * dist;
    }
    
//    float dist = distance(points[0].xy, float2(x, y));
//    return float4(dist * points[2].color, 1);
    
    return float4(finalColor, 1);
}

fragment float4 metaball_fragment(float4 pos[[position]],
                                  constant Metaball *points[[buffer(0)]],
                                  constant GlobalParameters& params[[buffer(1)]])
{
    float x = pos.x / params.size.x;
    float y = pos.y / params.size.y;
    
    float4 color = calculate_metaball_color(x, y, points, params);
    return color;
}

fragment float4
metaball_fragment_displacement(float4 pos[[position]],
                               constant Metaball *points[[buffer(0)]],
                               constant GlobalParameters& params[[buffer(1)]],
                               texture2d<float, access::sample> texture [[texture(2)]])
{
    constexpr sampler s(coord::normalized,
                        address::repeat,
                        filter::linear);
    float x = pos.x / params.size.x;
    float y = pos.y / params.size.y;
    
    float scale = params.scale;
    float4 sampledColor = texture.sample(s, float2(x*scale, y*scale));
    x += 200 / params.size.x * (sampledColor.r - 0.5);
    y += 200 / params.size.y * (sampledColor.g - 0.5);
    
    float4 color = calculate_metaball_color(x, y, points, params);
    return color;
}


