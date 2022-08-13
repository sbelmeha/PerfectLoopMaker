//
//  Shaders.metal
//  Perfect Loop Maker
//
//  Created by Sviatoslav Belmeha on 27.05.2022.
//

#include <metal_stdlib>
#include "MTIShaderLib.h"
#include "MTIShaderFunctionConstants.h"

using namespace metal;
using namespace metalpetal;

fragment float4 filter_fragment(VertexOut vertexIn [[stage_in]],
                              texture2d<float, access::sample> sourceTexture [[texture(0)]],
                              texture2d<float, access::sample> secondSourceTexture [[texture(1)]],
                              texture2d<float, access::sample> flowTexture [[texture(2)]],
                              sampler sourceSampler [[sampler(0)]],
                              constant float &time [[buffer(0)]],
                              constant float &startTime [[buffer(1)]],
                              constant float &endTime [[buffer(2)]]
                              )
{
    constexpr sampler s(address::clamp_to_edge, filter::linear);
    
    float2 val = flowTexture.sample(sourceSampler, vertexIn.textureCoordinate).xy;
    float2 flow = val / float2(sourceTexture.get_width(), sourceTexture.get_height());

    float4 col1 = sourceTexture.sample(s, vertexIn.textureCoordinate);
    float4 col2 = secondSourceTexture.sample(s, vertexIn.textureCoordinate);
    
    if (time >= startTime && time <= endTime) {
        float t = float(time - startTime) / float(endTime - startTime);

        float2 flow_fin2 = (-flow * (1.0 - t));
        float2 flow_fin1 = (flow * t);
        
        col1 = sourceTexture.sample(s,vertexIn.textureCoordinate - flow_fin1);
        col2 = secondSourceTexture.sample(s,vertexIn.textureCoordinate - flow_fin2);
        
        return (1.0 - t) * col1 + t * col2;
    } else if (time > startTime) {
        return col2;
    } else {
        return col1;
    }
}
