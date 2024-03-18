import {Image, StyleSheet, Text, View} from 'react-native';
import Toast, {
    BaseToast,
    ErrorToast,
    ToastConfig,
} from 'react-native-toast-message';
export {Toast};

const style = StyleSheet.create({
    success: {
        borderLeftColor: 'transparent',
        height: 'auto',
        padding: 5,
    },
    icon: {
        width: 20,
        aspectRatio: 1,
        objectFit: 'contain',
    },
});

export const toastConfig: ToastConfig = {
    /*
      Overwrite 'success' type,
      by modifying the existing `BaseToast` component
    */
    success: props => (
        <BaseToast
            {...props}
            style={style.success}
            contentContainerStyle={{paddingHorizontal: 15}}
            renderLeadingIcon={() => (
                <Image
                    style={style.icon}
                    source={require('@view/settings/message.png')}
                />
            )}
            text1Style={{
                fontSize: 15,
                fontWeight: '400',
            }}
        />
    ),
    /*
      Overwrite 'error' type,
      by modifying the existing `ErrorToast` component
    */
    error: props => (
        <ErrorToast
            {...props}
            text1Style={{
                fontSize: 17,
            }}
            text2Style={{
                fontSize: 15,
            }}
        />
    ),
    /*
      Or create a completely new type - `tomatoToast`,
      building the layout from scratch.
  
      I can consume any custom `props` I want.
      They will be passed when calling the `show` method (see below)
    */
    tomatoToast: ({text1, props}) => (
        <View style={{height: 60, width: '100%', backgroundColor: 'tomato'}}>
            <Text>{text1}</Text>
            <Text>{props.uuid}</Text>
        </View>
    ),
};