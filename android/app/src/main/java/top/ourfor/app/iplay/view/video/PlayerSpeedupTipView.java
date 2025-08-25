package top.ourfor.app.iplay.view.video;

import android.annotation.SuppressLint;
import android.content.Context;
import android.content.res.ColorStateList;
import android.graphics.Color;
import android.graphics.drawable.GradientDrawable;
import android.view.LayoutInflater;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.constraintlayout.widget.ConstraintLayout;

import lombok.Getter;
import top.ourfor.app.iplay.databinding.PlayerSelectItemBinding;
import top.ourfor.app.iplay.databinding.PlayerSpeedupTipViewBinding;
import top.ourfor.app.iplay.util.DeviceUtil;

@Getter
public class PlayerSpeedupTipView extends ConstraintLayout {
    static int normalColor = Color.parseColor("#88000000");

    PlayerSpeedupTipViewBinding binding;

    @SuppressLint("ResourceType")
    public PlayerSpeedupTipView(@NonNull Context context) {
        super(context);
        binding = PlayerSpeedupTipViewBinding.inflate(LayoutInflater.from(context), this, true);
        setupUI(context);
    }

    private void setupUI(Context context) {
        GradientDrawable gradientDrawable = new GradientDrawable();
        gradientDrawable.setColor(normalColor);
        gradientDrawable.setCornerRadius(DeviceUtil.dpToPx(12));
        setBackground(gradientDrawable);
    }

    public void setText(String text) {
        binding.speedLabel.setText(text);
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
