package top.ourfor.app.iplay.page.home;

import static top.ourfor.app.iplay.module.Bean.XGET;

import android.content.Context;
import android.graphics.drawable.GradientDrawable;
import android.util.AttributeSet;
import android.view.LayoutInflater;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.constraintlayout.widget.ConstraintLayout;
import androidx.core.content.ContextCompat;

import com.bumptech.glide.Glide;
import com.bumptech.glide.load.resource.bitmap.RoundedCorners;
import com.bumptech.glide.request.RequestOptions;

import lombok.Getter;
import lombok.Setter;
import lombok.val;
import top.ourfor.app.iplay.R;
import top.ourfor.app.iplay.action.UpdateModelAction;
import top.ourfor.app.iplay.bean.INavigator;
import top.ourfor.app.iplay.databinding.RecommendationItemBinding;
import top.ourfor.app.iplay.model.MediaModel;
import top.ourfor.app.iplay.util.DeviceUtil;

public class RecommendationItemView extends ConstraintLayout implements UpdateModelAction {
    private RecommendationItemBinding binding;
    
    @Getter @Setter
    private MediaModel media;
    
    @Getter @Setter
    private OnClickListener onTapListener;

    public interface OnClickListener {
        void onClick(MediaModel media);
    }

    public RecommendationItemView(@NonNull Context context) {
        super(context);
        setupUI(context);
    }

    public RecommendationItemView(@NonNull Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        setupUI(context);
    }

    public RecommendationItemView(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        setupUI(context);
    }

    private void setupUI(Context context) {
        val layout = new ConstraintLayout.LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT);
        setLayoutParams(layout);
        binding = RecommendationItemBinding.inflate(LayoutInflater.from(context), this, true);

        // 设置点击事件
        binding.getRoot().setOnClickListener(v -> {
            if (media != null) {
                if (onTapListener != null) {
                    onTapListener.onClick(media);
                } else {
                    // 默认导航行为
                    navigateToMedia(media);
                }
            }
        });

        // TV焦点处理
        if (DeviceUtil.isTV) {
            setFocusable(true);
            setOnFocusChangeListener((v, hasFocus) -> {
                float scale = hasFocus ? 1.1f : 1.0f;
                animate().scaleX(scale).scaleY(scale).setDuration(200).start();
            });
        }
    }

    public void setMedia(MediaModel media) {
        this.media = media;
        updateModel(media);
    }

    @Override
    public <T> void updateModel(T model) {
        if (!(model instanceof MediaModel media)) {
            return;
        }

        this.media = media;

        // 设置标题和类型
        binding.titleText.setText(media.getTitle() != null ? media.getTitle() : "未知标题");
        binding.typeText.setText(media.getType() != null ? media.getType() : "");

        // 加载背景图片
        String backdropUrl = media.getImage() != null ? media.getImage().getBackdrop() : null;
        if (backdropUrl != null && !backdropUrl.isEmpty()) {
            Glide.with(getContext())
                .load(backdropUrl)
                .apply(new RequestOptions()
                    .transform(new RoundedCorners(DeviceUtil.dpToPx(8))))
                .into(binding.backgroundImage);
        } else {
            binding.backgroundImage.setImageDrawable(createGradientPlaceholder());
        }
    }

    private GradientDrawable createGradientPlaceholder() {
        GradientDrawable drawable = new GradientDrawable();
        drawable.setOrientation(GradientDrawable.Orientation.TL_BR);
        
        int[] colors = generateGradientColors(media != null ? media.getType() : null);
        drawable.setColors(colors);
        drawable.setCornerRadius(DeviceUtil.dpToPx(8));
        
        return drawable;
    }

    private int[] generateGradientColors(String type) {
        Context context = getContext();
        if ("Movie".equals(type)) {
            return new int[]{
                ContextCompat.getColor(context, R.color.red_400),
                ContextCompat.getColor(context, R.color.orange_400)
            };
        } else if ("Series".equals(type)) {
            return new int[]{
                ContextCompat.getColor(context, R.color.blue_400),
                ContextCompat.getColor(context, R.color.purple_400)
            };
        } else if ("Episode".equals(type)) {
            return new int[]{
                ContextCompat.getColor(context, R.color.green_400),
                ContextCompat.getColor(context, R.color.teal_400)
            };
        } else {
            return new int[]{
                ContextCompat.getColor(context, R.color.purple_400),
                ContextCompat.getColor(context, R.color.pink_400)
            };
        }
    }

    private void navigateToMedia(MediaModel media) {
        val navigator = XGET(INavigator.class);
        if (navigator != null) {
            val args = new java.util.HashMap<String, Object>();
            args.put("id", media.getId());
            args.put("title", media.getTitle());
            
            int dstId = R.id.mediaPage;
            if (media.isMusicAlbum()) {
                dstId = R.id.musicPage;
            } else if (media.isAudio()) {
                dstId = R.id.musicPlayerPage;
            }
            navigator.pushPage(dstId, args);
        }
    }
}