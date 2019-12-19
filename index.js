import { NativeModules, Platform } from 'react-native';

const ImageCropper = Platform.OS == 'ios' ? NativeModules.RNDynamicCropper : NativeModules.ImageDynamicCropper;

export default ImageCropper;
