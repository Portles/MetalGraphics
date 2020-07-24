//
//  Shaders.metal
//  Oyn
//
//  Created by Nizamet Özkan on 24.07.2020.
//  Copyright © 2020 NizoOrganizatsiyon. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct VertexIn{
    float3 position [[ attribute(0) ]];
    float4 color [[ attribute(1) ]];
};

struct VertexOut{
    float4 position [[ position ]];
    float4 color;
};

struct Constants {
    float animatedBy;
};

vertex VertexOut basic_vertex_function(const VertexIn vIn [[ stage_in ]],
                                       constant Constants &constants [[buffer(1)]]){
    
    VertexOut vOut;
    vOut.position = float4(vIn.position,1);
    vOut.position.xy += cos(constants.animatedBy);
    vOut.position.y += sin(constants.animatedBy);
    vOut.color = vIn.color;
    return vOut;
}

fragment float4 basic_fragment_function(VertexOut vIn [[ stage_in ]]){
    return vIn.color;
}
