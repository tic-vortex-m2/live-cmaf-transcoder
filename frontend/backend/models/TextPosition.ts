/* tslint:disable */
/* eslint-disable */
/**
 * live-cmaf-transcoder
 * API for the Live CMAF Transcoder
 *
 * The version of the OpenAPI document: 0.1.52
 * 
 *
 * NOTE: This class is auto generated by OpenAPI Generator (https://openapi-generator.tech).
 * https://openapi-generator.tech
 * Do not edit the class manually.
 */


/**
 * 
 * @export
 */
export const TextPosition = {
    TopLeft: 'TopLeft',
    TopCenter: 'TopCenter',
    TopRight: 'TopRight',
    MiddleLeft: 'MiddleLeft',
    MiddleCenter: 'MiddleCenter',
    MiddleRight: 'MiddleRight',
    BottomLeft: 'BottomLeft',
    BottomCenter: 'BottomCenter',
    BottomRight: 'BottomRight'
} as const;
export type TextPosition = typeof TextPosition[keyof typeof TextPosition];


export function instanceOfTextPosition(value: any): boolean {
    for (const key in TextPosition) {
        if (Object.prototype.hasOwnProperty.call(TextPosition, key)) {
            if (TextPosition[key as keyof typeof TextPosition] === value) {
                return true;
            }
        }
    }
    return false;
}

export function TextPositionFromJSON(json: any): TextPosition {
    return TextPositionFromJSONTyped(json, false);
}

export function TextPositionFromJSONTyped(json: any, ignoreDiscriminator: boolean): TextPosition {
    return json as TextPosition;
}

export function TextPositionToJSON(value?: TextPosition | null): any {
    return value as any;
}

export function TextPositionToJSONTyped(value: any, ignoreDiscriminator: boolean): TextPosition {
    return value as TextPosition;
}

