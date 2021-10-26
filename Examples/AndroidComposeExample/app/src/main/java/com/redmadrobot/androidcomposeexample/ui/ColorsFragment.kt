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

class ColorsFragment : Fragment() {

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        val view = inflater.inflate(R.layout.fragment_colors, container, false) as ComposeView?
        view?.apply {
            setViewCompositionStrategy(ViewCompositionStrategy.DisposeOnViewTreeLifecycleDestroyed)
            setContent {
                MdcTheme {
                    Box {
                        Column(
                            modifier = Modifier.padding(10.dp),
                            verticalArrangement = Arrangement.spacedBy(10.dp)
                        ) {
                            Text(
                                "Text on primary background",
                                color = Colors.textSecondary(),
                                modifier = Modifier.wrapContentSize()
                            )
                            Text(
                                "Text on secondary background",
                                color = Colors.textSecondary(),
                                modifier = Modifier
                                    .wrapContentHeight()
                                    .fillMaxWidth()
                                    .background(Colors.backgroundSecondary())
                                    .padding(10.dp)
                            )
                            Row(
                                modifier = Modifier.fillMaxWidth(),
                                horizontalArrangement = Arrangement.SpaceBetween
                            ) {
                                var switchChecked by remember { mutableStateOf(false) }
                                Text(
                                    "Switch color",
                                    color = Colors.textSecondary(),
                                    modifier = Modifier.wrapContentSize()
                                )
                                Switch(
                                    switchChecked,
                                    { switchChecked = !switchChecked },
                                    modifier = Modifier.wrapContentSize(),
                                    colors = SwitchDefaults.colors(checkedThumbColor = Colors.button())
                                )
                            }
                            Row(
                                modifier = Modifier.fillMaxWidth(),
                                horizontalArrangement = Arrangement.SpaceBetween
                            ) {
                                var radioButtonSelected by remember { mutableStateOf(false) }
                                Text(
                                    "RadioButton color",
                                    color = Colors.textSecondary(),
                                    modifier = Modifier.wrapContentSize()
                                )
                                RadioButton(
                                    radioButtonSelected,
                                    { radioButtonSelected = !radioButtonSelected },
                                    modifier = Modifier.wrapContentSize(),
                                    colors = RadioButtonDefaults.colors(selectedColor = Colors.button())
                                )
                            }

                        }
                        Button(
                            { },
                            Modifier
                                .wrapContentHeight()
                                .fillMaxWidth()
                                .align(Alignment.BottomCenter)
                                .padding(20.dp),
                            colors = ButtonDefaults.buttonColors(backgroundColor = Colors.button()),
                        ) {
                            Text(
                                "Solid button",
                                color = Colors.textPrimary(),
                                modifier = Modifier.wrapContentSize()
                            )
                        }
                    }
                }
            }
        }
        return view
    }
}