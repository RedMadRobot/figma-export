package com.redmadrobot.androidcomposeexample.ui

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.compose.foundation.layout.*
import androidx.compose.material.Text
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.ComposeView
import androidx.compose.ui.platform.ViewCompositionStrategy
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import androidx.fragment.app.Fragment
import com.google.android.material.composethemeadapter.MdcTheme
import com.redmadrobot.androidcomposeexample.R
import com.redmadrobot.androidcomposeexample.ui.figmaexport.*

class TypographyFragment : Fragment() {

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        val view = inflater.inflate(R.layout.fragment_typography, container, false) as ComposeView?
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
                            horizontalAlignment = Alignment.Start
                        ) {
                            Text(
                                text = stringResource(id = R.string.label_large_title),
                                color = Colors.textSecondary(),
                                style = Typography.largeTitle
                            )
                            Text(
                                text = stringResource(id = R.string.label_header),
                                color = Colors.textSecondary(),
                                style = Typography.header
                            )
                            Text(
                                text = stringResource(id = R.string.label_body),
                                color = Colors.textSecondary(),
                                style = Typography.body
                            )
                            Text(
                                text = stringResource(id = R.string.label_caption),
                                color = Colors.textSecondary(),
                                style = Typography.caption
                            )
                        }
                    }
                }
            }
        }
        return view
    }
}