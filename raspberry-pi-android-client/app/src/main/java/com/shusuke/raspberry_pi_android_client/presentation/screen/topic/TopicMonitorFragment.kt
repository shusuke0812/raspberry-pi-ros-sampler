package com.shusuke.raspberry_pi_android_client.presentation.screen.topic

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
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.lifecycleScope
import androidx.lifecycle.repeatOnLifecycle
import com.shusuke.raspberry_pi_android_client.R
import com.shusuke.raspberry_pi_android_client.presentation.dialog.ErrorDialogFragment
import com.shusuke.raspberry_pi_android_client.presentation.screen.topic.compose.TopicMonitorScreen
import com.shusuke.raspberry_pi_android_client.ui.theme.RaspberrypiandroidclientTheme
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.launch
import org.koin.androidx.viewmodel.ext.android.viewModel

class TopicMonitorFragment : Fragment() {

    private val viewModel: TopicMonitorViewModel by viewModel()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        childFragmentManager.setFragmentResultListener(
            ErrorDialogFragment.REQUEST_KEY,
            this,
        ) { _, _ ->
            viewModel.hideErrorAlert()
        }
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        viewLifecycleOwner.lifecycleScope.launch {
            repeatOnLifecycle(Lifecycle.State.STARTED) {
                combine(
                    viewModel.isErrorPresented,
                    viewModel.uiState,
                ) { isError, state -> isError to state }
                    .collect { (isError, state) ->
                        if (isError && state is TopicMonitorViewModel.UiState.Failure) {
                            val existing = childFragmentManager.findFragmentByTag(ErrorDialogFragment.TAG)
                            if (existing == null) {
                                ErrorDialogFragment.newInstance(
                                    getString(R.string.error_dialog_title),
                                    state.error.message,
                                ).show(childFragmentManager, ErrorDialogFragment.TAG)
                            }
                        }
                    }
            }
        }
    }

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?,
    ): View = ComposeView(requireContext()).apply {
        setViewCompositionStrategy(ViewCompositionStrategy.DisposeOnViewTreeLifecycleDestroyed)
        setContent {
            RaspberrypiandroidclientTheme {
                Surface(modifier = Modifier.fillMaxSize()) {
                    TopicMonitorScreen(viewModel = viewModel)
                }
            }
        }
    }
}
