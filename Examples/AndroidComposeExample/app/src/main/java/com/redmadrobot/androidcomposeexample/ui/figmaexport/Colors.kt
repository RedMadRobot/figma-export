package com.redmadrobot.androidcomposeexample.ui.figmaexport

import androidx.compose.runtime.Composable
import androidx.compose.runtime.ReadOnlyComposable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.colorResource
import com.redmadrobot.androidcomposeexample.R

object Colors

@Composable
@ReadOnlyComposable
fun Colors.backgroundPrimary(): Color = colorResource(id = R.color.background_primary)

@Composable
@ReadOnlyComposable
fun Colors.backgroundSecondary(): Color = colorResource(id = R.color.background_secondary)

@Composable
@ReadOnlyComposable
fun Colors.button(): Color = colorResource(id = R.color.button)

@Composable
@ReadOnlyComposable
fun Colors.buttonRipple(): Color = colorResource(id = R.color.button_ripple)

@Composable
@ReadOnlyComposable
fun Colors.textPrimary(): Color = colorResource(id = R.color.text_primary)

@Composable
@ReadOnlyComposable
fun Colors.textSecondary(): Color = colorResource(id = R.color.text_secondary)

@Composable
@ReadOnlyComposable
fun Colors.tint(): Color = colorResource(id = R.color.tint)
