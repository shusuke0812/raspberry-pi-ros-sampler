package com.shusuke.raspberry_pi_android_client.presentation.connection

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.Surface
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.ComposeView
import androidx.compose.ui.platform.ViewCompositionStrategy
import androidx.fragment.app.Fragment
import com.shusuke.raspberry_pi_android_client.presentation.connection.compose.ConnectionScreen
import com.shusuke.raspberry_pi_android_client.ui.theme.RaspberrypiandroidclientTheme
import org.koin.androidx.viewmodel.ext.android.viewModel

class ConnectionFragment : Fragment() {

    private val viewModel: ConnectionViewModel by viewModel()

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?,
    ): View = ComposeView(requireContext()).apply {
        setViewCompositionStrategy(ViewCompositionStrategy.DisposeOnViewTreeLifecycleDestroyed)
        setContent {
            RaspberrypiandroidclientTheme {
                Surface(modifier = Modifier.fillMaxSize()) {
                    ConnectionScreen(viewModel = viewModel)
                }
            }
        }
    }
}
