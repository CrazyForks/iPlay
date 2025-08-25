package top.ourfor.app.iplay.view.video;

import android.annotation.SuppressLint;
import android.content.Context;
import android.content.res.ColorStateList;
import android.graphics.Color;
import android.graphics.drawable.GradientDrawable;
import android.view.LayoutInflater;

import androidx.annotation.NonNull;
import androidx.constraintlayout.widget.ConstraintLayout;

import top.ourfor.app.iplay.databinding.PlayerNumberValueViewBinding;
import top.ourfor.app.iplay.util.DeviceUtil;

public class PlayerNumberValueView extends ConstraintLayout {
    private PlayerNumberValueViewBinding binding;

    public PlayerNumberValueView(@NonNull Context context) {
        super(context);
        binding = PlayerNumberValueViewBinding.inflate(LayoutInflater.from(context), this, true);
        setupUI(context);
    }

    @SuppressLint("ResourceType")
    void setupUI(Context context) {
        GradientDrawable gradientDrawable = new GradientDrawable();
        gradientDrawable.setColor(Color.argb(50, 0, 0, 0));
        gradientDrawable.setCornerRadius(DeviceUtil.dpToPx(12));
        setBackground(gradientDrawable);
    }

    public void setProgress(int progress) {
        post(() -> {
            var abs_progress = Math.abs(progress);
            binding.slider.setValue(abs_progress);
        });
    }

    public void setMaxValue(int value) {
        post(() -> {
            var abs_value = Math.abs(value);
            binding.slider.setValueTo(abs_value);
        });
    }

    public void updateIcon(int icon) {
        post(() -> {
            binding.icon.setImageResource(icon);
            binding.icon.setImageTintList(ColorStateList.valueOf(Color.WHITE));
        });
    }

    public int getProgress() {
        return (int) (binding.slider.getValue());
    }

    public void show() {
        animate().alpha(1)
                .setDuration(150)
                .start();
    }

    public void hide() {
        animate().alpha(0)
                .setStartDelay(300)
                .setDuration(200)
                .start();
    }
}
