package top.ourfor.app.iplay.model;

import com.fasterxml.jackson.annotation.JsonProperty;

import java.util.List;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.With;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@With
public class ImageModel {
    @JsonProperty("primary")
    String primary;
    @JsonProperty("backdrop")
    String backdrop;
    @JsonProperty("logo")
    String logo;
    @JsonProperty("thumb")
    String thumb;

    @JsonProperty("fallback")
    List<String> fallback;
    
    @JsonProperty("backdrops")
    List<String> backdrops;
    
    // 获取所有背景图片，包括主背景图和额外背景图
    public List<String> getAllBackdrops() {
        List<String> allBackdrops = new java.util.ArrayList<>();
        if (backdrops != null && !backdrops.isEmpty()) {
            allBackdrops.addAll(backdrops);
        } else if (backdrop != null && !backdrop.isEmpty()) {
            allBackdrops.add(backdrop);
        }
        return allBackdrops;
    }
}
