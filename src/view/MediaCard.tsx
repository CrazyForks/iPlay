import { imageUrl } from '@api/config';
import {
    Image, StyleSheet, Text,
    TouchableOpacity, TouchableWithoutFeedback, TouchableWithoutFeedbackBase, View
} from 'react-native';
import { Media } from '@model/Media';
import { useNavigation } from '@react-navigation/native';
import { Navigation } from '@global';

export const style = StyleSheet.create({
    mediaCard: {
        margin: 10,
        overflow: 'hidden',
        maxWidth: '33%',
        alignItems: 'center',
    }
});

export function MediaCard({ media }: { media: Media; }) {
    const navigation: Navigation = useNavigation();
    const onPress = (media: Media) => {
        navigation.navigate('movie', {
            title: media.Name,
            type: media.Type,
            movie: media,
        });
    };
    return (
            <View style={style.mediaCard} key={media.Id}>
                <TouchableWithoutFeedback onPress={() => onPress(media)}>
                <Image
                    style={{ width: 90, aspectRatio: 4.6/7, borderRadius: 5 }}
                    source={{ uri: imageUrl(media.Id, null) }} />
                </TouchableWithoutFeedback>
                <Text style={{ maxWidth: 90, overflow: 'hidden' }}>
                    {media.Name}
                </Text>
                <Text>{media.ProductionYear}</Text>
            </View>
    );
}