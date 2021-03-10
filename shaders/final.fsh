uniform sampler2D gcolor;

#define ColorBlindnessType 0 //[0 1 2 3 4]
#define Severity 100 //[0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100]
varying vec4 texcoord;

// Constants
const float SRGB_ALPHA = 0.055;
// Used to convert from linear RGB to XYZ space
const mat3 RGB_2_LMS = (mat3(
    0.31399022, 0.15537241, 0.01775239,
    0.63951294, 0.75789446, 0.10944209,
    0.04649755, 0.08670142, 0.87256922
));

// Used to convert from XYZ to linear RGB space
const mat3 LMS_2_RGB = (mat3(
     5.47221206,-1.1252419, 0.02980165,
    -4.6419601, 2.29317094,-0.19318073,
    0.16963708, -0.1678952, 1.16364789
));

// Converts a color from linear RGB to XYZ space
vec3 rgb_to_lms(vec3 rgb) {
    return RGB_2_LMS * rgb;
}

// Converts a color from XYZ to linear RGB space
vec3 lms_to_rgb(vec3 lms) {
    return LMS_2_RGB * lms;
}
// Converts a single linear channel to srgb
float linear_to_srgb(float channel) {
    if(channel <= 0.0031308)
        return 12.92 * channel;
    else
        return (1.0 + SRGB_ALPHA) * pow(channel, 1.0/2.4) - SRGB_ALPHA;
}

// Converts a single srgb channel to rgb
float srgb_to_linear(float channel) {
    if (channel <= 0.04045)
        return channel / 12.92;
    else
        return pow((channel + SRGB_ALPHA) / (1.0 + SRGB_ALPHA), 2.4);
}

// Converts a linear rgb color to a srgb color (exact, not approximated)
vec3 rgb_to_srgb(vec3 rgb) {
    return vec3(
        linear_to_srgb(rgb.r),
        linear_to_srgb(rgb.g),
        linear_to_srgb(rgb.b)
    );
}

// Converts a srgb color to a linear rgb color (exact, not approximated)
vec3 srgb_to_rgb(vec3 srgb) {
    return vec3(
        srgb_to_linear(srgb.r),
        srgb_to_linear(srgb.g),
        srgb_to_linear(srgb.b)
    );
}

void main(){

  vec3 c = texture2D(gcolor, texcoord.st).rgb;

mat3 m[5] =
{
      // normal
	mat3(1.0, 0.0, 0.0,
      0.0, 1.0, 0.0,
      0.0, 0.0, 1.0),
      // protanopia
  mat3(0.0, 1.05118294, -0.05116099,
      0.0, 1.0, 0.0,
      0.0, 0.0, 1.0),
      // deuteranopia
      mat3(1.0, 0.0, 0.0,
          0.9513092, 0.0, 0.04866992,
          0.0, 0.0, 1.0),
      // tritanopia
      mat3(1.0, 0.0, 0.0,
          0.0, 1.0, 0.0,
          -0.86744736, 1.86727089, 0.0),
      // achromatopsia
      mat3(0.212656, 0.715158, 0.072186,
          0.212656, 0.715158, 0.072186,
          0.212656, 0.715158, 0.072186)
};

mat3 CurrentColors = (mat3(
  mix(m[0][0][0],m[ColorBlindnessType][0][0],Severity/100.0),mix(m[0][0][1],m[ColorBlindnessType][0][1],Severity/100.0),mix(m[0][0][2],m[ColorBlindnessType][0][2],Severity/100.0),
  mix(m[0][1][0],m[ColorBlindnessType][1][0],Severity/100.0),mix(m[0][1][1],m[ColorBlindnessType][1][1],Severity/100.0),mix(m[0][1][2],m[ColorBlindnessType][1][2],Severity/100.0),
  mix(m[0][2][0],m[ColorBlindnessType][2][0],Severity/100.0),mix(m[0][2][1],m[ColorBlindnessType][2][1],Severity/100.0),mix(m[0][2][2],m[ColorBlindnessType][2][2],Severity/100.0)
  ));

vec3 c2 = vec3(c.r, c.g, c.b);
c2 = srgb_to_rgb(c2);
c2 = rgb_to_lms(c2);
c2 = c2 * CurrentColors;
c2 = lms_to_rgb(c2);
c2 = rgb_to_srgb(c2);
gl_FragColor = vec4( c2.x , c2.y, c2.z, 1.0f);
}
