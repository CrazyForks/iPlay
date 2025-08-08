package top.ourfor.app.iplay.view;

import lombok.Builder;
import lombok.Data;
import lombok.With;

@Data
@Builder
@With
public class ListDiffModel<T> {
    T data;
    boolean isSelected;
}
