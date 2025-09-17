package top.ourfor.app.iplay.page.media;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.constraintlayout.widget.ConstraintLayout;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.bumptech.glide.Glide;
import com.bumptech.glide.load.resource.bitmap.RoundedCorners;
import com.bumptech.glide.request.RequestOptions;

import java.util.ArrayList;
import java.util.List;

import lombok.Getter;
import lombok.Setter;
import lombok.val;
import top.ourfor.app.iplay.R;
import top.ourfor.app.iplay.databinding.MediaBackdropItemBinding;
import top.ourfor.app.iplay.databinding.MediaBackdropListBinding;
import top.ourfor.app.iplay.util.DeviceUtil;

public class MediaBackdropListView extends ConstraintLayout {
    private MediaBackdropListBinding binding;
    private BackdropAdapter adapter;
    
    @Getter @Setter
    private List<String> backdrops = new ArrayList<>();
    
    @Getter @Setter
    private int selectedBackdropIndex = 0;
    
    @Getter @Setter
    private OnBackdropSelectedListener onBackdropSelectedListener;

    public interface OnBackdropSelectedListener {
        void onBackdropSelected(int index, String backdropUrl);
    }

    public MediaBackdropListView(@NonNull Context context) {
        super(context);
        setupUI(context);
    }

    public MediaBackdropListView(@NonNull Context context, android.util.AttributeSet attrs) {
        super(context, attrs);
        setupUI(context);
    }

    public MediaBackdropListView(@NonNull Context context, android.util.AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        setupUI(context);
    }

    private void setupUI(Context context) {
        val layout = new ConstraintLayout.LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT);
        setLayoutParams(layout);
        binding = MediaBackdropListBinding.inflate(LayoutInflater.from(context), this, true);

        // 设置RecyclerView
        adapter = new BackdropAdapter();
        binding.recyclerView.setAdapter(adapter);
        binding.recyclerView.setLayoutManager(new LinearLayoutManager(context, LinearLayoutManager.HORIZONTAL, false));
    }

    public void setBackdrops(List<String> backdrops) {
        this.backdrops = backdrops != null ? backdrops : new ArrayList<>();
        adapter.setBackdrops(this.backdrops);
        adapter.notifyDataSetChanged();
    }

    public void setSelectedBackdropIndex(int index) {
        if (index >= 0 && index < backdrops.size() && index != selectedBackdropIndex) {
            int oldIndex = this.selectedBackdropIndex;
            this.selectedBackdropIndex = index;
            
            // 更新适配器中的选中状态
            adapter.notifyItemChanged(oldIndex);
            adapter.notifyItemChanged(index);
            
            // 滚动到选中项
            binding.recyclerView.smoothScrollToPosition(index);
            
            // 回调监听器
            if (onBackdropSelectedListener != null) {
                onBackdropSelectedListener.onBackdropSelected(index, backdrops.get(index));
            }
        }
    }

    // RecyclerView适配器
    private class BackdropAdapter extends RecyclerView.Adapter<BackdropViewHolder> {
        private List<String> items = new ArrayList<>();

        public void setBackdrops(List<String> items) {
            this.items = items != null ? items : new ArrayList<>();
        }

        @NonNull
        @Override
        public BackdropViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            MediaBackdropItemBinding binding = MediaBackdropItemBinding.inflate(
                LayoutInflater.from(parent.getContext()), parent, false);
            return new BackdropViewHolder(binding);
        }

        @Override
        public void onBindViewHolder(@NonNull BackdropViewHolder holder, int position) {
            if (position < items.size()) {
                holder.bind(items.get(position), position);
            }
        }

        @Override
        public int getItemCount() {
            return items.size();
        }
    }

    // ViewHolder
    private class BackdropViewHolder extends RecyclerView.ViewHolder {
        private final MediaBackdropItemBinding binding;

        public BackdropViewHolder(MediaBackdropItemBinding binding) {
            super(binding.getRoot());
            this.binding = binding;
        }

        public void bind(String backdropUrl, int position) {
            // 加载图片
            if (backdropUrl != null && !backdropUrl.isEmpty()) {
                Glide.with(binding.backdropImage.getContext())
                    .load(backdropUrl)
                    .apply(new RequestOptions()
                        .transform(new RoundedCorners(DeviceUtil.dpToPx(8)))
                        .placeholder(R.drawable.hand_drawn_3)
                        .error(R.drawable.hand_drawn_3))
                    .into(binding.backdropImage);
            } else {
                binding.backdropImage.setImageResource(R.drawable.hand_drawn_3);
            }

            // 设置选中状态 - 切换边框背景，避免视图抖动
            boolean isSelected = position == selectedBackdropIndex;
            if (isSelected) {
                binding.selectionBorder.setBackgroundResource(R.drawable.selected_border);
                binding.cardView.setCardElevation(DeviceUtil.dpToPx(8));
            } else {
                binding.selectionBorder.setBackgroundResource(R.drawable.unselected_border);
                binding.cardView.setCardElevation(DeviceUtil.dpToPx(4));
            }

            // 设置点击事件
            binding.getRoot().setOnClickListener(v -> {
                setSelectedBackdropIndex(position);
            });

            // TV焦点处理
            if (DeviceUtil.isTV) {
                binding.getRoot().setFocusable(true);
                binding.getRoot().setOnFocusChangeListener((v, hasFocus) -> {
                    float scale = hasFocus ? 1.1f : 1.0f;
                    v.animate().scaleX(scale).scaleY(scale).setDuration(200).start();
                });
            }
        }
    }
}