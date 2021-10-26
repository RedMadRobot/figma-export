package com.redmadrobot.androidcomposeexample.ui.figmaexport

import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.Font
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.unit.sp
import com.redmadrobot.androidcomposeexample.R

object Typography {

    val body = TextStyle(
        fontFamily = FontFamily(Font(R.font.ptsans_regular)),
        fontSize = 16.0.sp,
        letterSpacing = 0.0.sp,
        lineHeight = 24.0.sp,
    )
    val caption = TextStyle(
        fontFamily = FontFamily(Font(R.font.ptsans_regular)),
        fontSize = 14.0.sp,
        letterSpacing = 0.0.sp,
        lineHeight = 20.0.sp,
    )
    val header = TextStyle(
        fontFamily = FontFamily(Font(R.font.ptsans_bold)),
        fontSize = 20.0.sp,
        letterSpacing = 0.0.sp,
    )
    val largeTitle = TextStyle(
        fontFamily = FontFamily(Font(R.font.ptsans_bold)),
        fontSize = 34.0.sp,
        letterSpacing = 0.0.sp,
    )
    val uppercased = TextStyle(
        fontFamily = FontFamily(Font(R.font.ptsans_regular)),
        fontSize = 14.0.sp,
        letterSpacing = 0.0.sp,
        lineHeight = 20.0.sp,
    )
}
