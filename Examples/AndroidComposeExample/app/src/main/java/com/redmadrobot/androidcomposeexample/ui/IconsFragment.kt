package com.redmadrobot.androidcomposeexample.ui

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.material.*
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.ComposeView
import androidx.compose.ui.platform.ViewCompositionStrategy
import androidx.compose.ui.unit.dp
import androidx.fragment.app.Fragment
import com.google.android.material.composethemeadapter.MdcTheme
import com.redmadrobot.androidcomposeexample.R
import com.redmadrobot.androidcomposeexample.ui.figmaexport.*
import com.redmadrobot.androidcomposeexample.ui.figmaexport.Colors

class IconsFragment : Fragment() {

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        val view = inflater.inflate(R.layout.fragment_icons, container, false) as ComposeView?
        view?.apply {
            setViewCompositionStrategy(ViewCompositionStrategy.DisposeOnViewTreeLifecycleDestroyed)
            setContent {
                MdcTheme {
                    Box {
                        Column(
                            modifier = Modifier
                                .padding(16.dp)
                                .wrapContentSize()
                                .align(Alignment.TopStart),
                            verticalArrangement = Arrangement.spacedBy(8.dp),
                            horizontalAlignment = Alignment.CenterHorizontally
                        ) {
                            Icons.Ic16KeyEmergency(
                                contentDescription = "emergency",
                                tint = Colors.tint()
                            )
                            Icons.Ic16KeySandglass(
                                contentDescription = "sandglass",
                                tint = Colors.tint()
                            )
                            Icons.Ic16Notification(
                                contentDescription = "notification",
                                tint = Colors.tint()
                            )
                            Icons.Ic24ArrowBack(
                                contentDescription = "arrow back",
                                tint = Colors.tint()
                            )
                            Icons.Ic24ShareAndroid(
                                contentDescription = "share",
                                tint = Colors.tint()
                            )
                            Icons.Ic24ArrowRight(
                                contentDescription = "arrow right",
                                tint = Colors.tint()
                            )
                            Icons.Ic24Close(
                                contentDescription = "close",
                                tint = Colors.tint()
                            )
                            Icons.Ic24DropdownDown(
                                contentDescription = "dropdown down",
                                tint = Colors.tint()
                            )
                            Icons.Ic24DropdownUp(
                                contentDescription = "dropdown up",
                                tint = Colors.tint()
                            )
                            Icons.Ic24FullscreenDisable(
                                contentDescription = "fullscreen disable",
                                tint = Colors.tint()
                            )
                            Icons.Ic24FullscreenEnable(
                                contentDescription = "fullscreen enable",
                                tint = Colors.tint()
                            )
                        }
                    }
                }
            }
        }
        return view
    }
}