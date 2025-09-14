package top.ourfor.app.iplay.page.home;

import static top.ourfor.app.iplay.module.Bean.XGET;

import android.content.Context;
import android.graphics.drawable.GradientDrawable;
import android.os.Handler;
import android.os.Looper;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.constraintlayout.widget.ConstraintLayout;
import androidx.core.content.ContextCompat;
import androidx.viewpager2.widget.ViewPager2;

import com.bumptech.glide.Glide;
import com.bumptech.glide.load.resource.bitmap.RoundedCorners;
import com.bumptech.glide.request.RequestOptions;

import java.util.ArrayList;
import java.util.List;

import lombok.Getter;
import lombok.Setter;
import lombok.val;
import top.ourfor.app.iplay.R;
import top.ourfor.app.iplay.bean.INavigator;
import top.ourfor.app.iplay.databinding.CarouselItemBinding;
import top.ourfor.app.iplay.databinding.CarouselViewBinding;
import top.ourfor.app.iplay.model.MediaModel;
import top.ourfor.app.iplay.util.DeviceUtil;

public class CarouselView extends ConstraintLayout {
    private CarouselViewBinding binding;
    private CarouselAdapter adapter;
    private Handler autoScrollHandler;
    private Runnable autoScrollRunnable;
    private static final int AUTO_SCROLL_DELAY = 3000; // 3秒自动轮播
    
    @Getter @Setter
    private List<MediaModel> recommendationMedias = new ArrayList<>();
    
    @Getter @Setter
    private int selectedIndex = 0;

    public CarouselView(@NonNull Context context) {
        super(context);
        setupUI(context);
    }

    public CarouselView(@NonNull Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        setupUI(context);
    }

    public CarouselView(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        setupUI(context);
    }

    private void setupUI(Context context) {
        val layout = new ConstraintLayout.LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT);
        setLayoutParams(layout);
        binding = CarouselViewBinding.inflate(LayoutInflater.from(context), this, true);

        // 设置适配器
        adapter = new CarouselAdapter();
        binding.viewPager.setAdapter(adapter);

        // 设置页面变化监听
        binding.viewPager.registerOnPageChangeCallback(new ViewPager2.OnPageChangeCallback() {
            @Override
            public void onPageSelected(int position) {
                selectedIndex = position;
                updateIndicators();
                resetAutoScroll();
            }
        });

        // 初始化自动滚动
        autoScrollHandler = new Handler(Looper.getMainLooper());
        autoScrollRunnable = this::moveToNextItem;
    }

    public void setRecommendationMedias(List<MediaModel> medias) {
        this.recommendationMedias = medias != null ? medias : new ArrayList<>();
        adapter.setItems(this.recommendationMedias);
        setupIndicators();
        startAutoScroll();
    }

    private void setupIndicators() {
        binding.indicatorLayout.removeAllViews();
        for (int i = 0; i < recommendationMedias.size(); i++) {
            View indicator = createIndicator();
            binding.indicatorLayout.addView(indicator);
            
            final int index = i;
            indicator.setOnClickListener(v -> {
                binding.viewPager.setCurrentItem(index);
            });
        }
        updateIndicators();
    }

    private View createIndicator() {
        View indicator = new View(getContext());
        int size = DeviceUtil.dpToPx(8);
        LinearLayout.LayoutParams params = new LinearLayout.LayoutParams(size, size);
        params.setMargins(DeviceUtil.dpToPx(4), 0, DeviceUtil.dpToPx(4), 0);
        indicator.setLayoutParams(params);
        
        GradientDrawable drawable = new GradientDrawable();
        drawable.setShape(GradientDrawable.OVAL);
        drawable.setColor(ContextCompat.getColor(getContext(), R.color.onBackground_lowContrast));
        indicator.setBackground(drawable);
        
        return indicator;
    }

    private void updateIndicators() {
        for (int i = 0; i < binding.indicatorLayout.getChildCount(); i++) {
            View indicator = binding.indicatorLayout.getChildAt(i);
            GradientDrawable drawable = new GradientDrawable();
            drawable.setShape(GradientDrawable.OVAL);
            
            if (i == selectedIndex) {
                drawable.setColor(ContextCompat.getColor(getContext(), R.color.primary));
            } else {
                drawable.setColor(ContextCompat.getColor(getContext(), R.color.onBackground_lowContrast));
            }
            indicator.setBackground(drawable);
        }
    }

    private void moveToNextItem() {
        if (recommendationMedias.isEmpty()) return;
        
        int nextIndex = (selectedIndex + 1) % recommendationMedias.size();
        binding.viewPager.setCurrentItem(nextIndex, true);
    }

    private void startAutoScroll() {
        stopAutoScroll();
        if (recommendationMedias.size() > 1) {
            autoScrollHandler.postDelayed(autoScrollRunnable, AUTO_SCROLL_DELAY);
        }
    }

    private void stopAutoScroll() {
        autoScrollHandler.removeCallbacks(autoScrollRunnable);
    }

    private void resetAutoScroll() {
        startAutoScroll();
    }

    @Override
    protected void onAttachedToWindow() {
        super.onAttachedToWindow();
        startAutoScroll();
    }

    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        stopAutoScroll();
    }

    // ViewPager2适配器
    private class CarouselAdapter extends androidx.recyclerview.widget.RecyclerView.Adapter<CarouselViewHolder> {
        private List<MediaModel> items = new ArrayList<>();

        public void setItems(List<MediaModel> items) {
            this.items = items != null ? items : new ArrayList<>();
            notifyDataSetChanged();
        }

        @NonNull
        @Override
        public CarouselViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            CarouselItemBinding binding = CarouselItemBinding.inflate(
                LayoutInflater.from(parent.getContext()), parent, false);
            return new CarouselViewHolder(binding);
        }

        @Override
        public void onBindViewHolder(@NonNull CarouselViewHolder holder, int position) {
            if (position < items.size()) {
                holder.bind(items.get(position));
            }
        }

        @Override
        public int getItemCount() {
            return items.size();
        }
    }

    // ViewHolder
    private class CarouselViewHolder extends androidx.recyclerview.widget.RecyclerView.ViewHolder {
        private final CarouselItemBinding binding;

        public CarouselViewHolder(CarouselItemBinding binding) {
            super(binding.getRoot());
            this.binding = binding;
        }

        public void bind(MediaModel media) {
            binding.titleText.setText(media.getTitle() != null ? media.getTitle() : "未知标题");
            binding.subtitleText.setText(media.getType() != null ? media.getType() : "");
            binding.descriptionText.setText(media.getOverview() != null ? media.getOverview() : "来自 iPlay 推荐");

            // 加载背景图片
            String backdropUrl = media.getImage() != null ? media.getImage().getBackdrop() : null;
            if (backdropUrl != null && !backdropUrl.isEmpty()) {
                Glide.with(binding.backgroundImage.getContext())
                    .load(backdropUrl)
                    .apply(new RequestOptions()
                        .transform(new RoundedCorners(DeviceUtil.dpToPx(16))))
                    .into(binding.backgroundImage);
            } else {
                // 设置默认背景
                binding.backgroundImage.setBackgroundColor(
                    ContextCompat.getColor(binding.backgroundImage.getContext(), R.color.purple_400));
            }

            // 设置点击事件
            binding.getRoot().setOnClickListener(v -> {
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
            });
        }
    }
}