package com.shusuke.raspberry_pi_android_client.presentation.dialog

import android.app.Dialog
import android.content.DialogInterface
import android.os.Bundle
import androidx.core.os.bundleOf
import androidx.fragment.app.DialogFragment
import com.google.android.material.dialog.MaterialAlertDialogBuilder
import com.shusuke.raspberry_pi_android_client.R

/**
 * エラー内容を表示する [DialogFragment]（プラン: Topic 等のエラー表示を Fragment ベースで統一）。
 */
class ErrorDialogFragment : DialogFragment() {

    override fun onCreateDialog(savedInstanceState: Bundle?): Dialog {
        val title = requireArguments().getString(ARG_TITLE).orEmpty()
        val message = requireArguments().getString(ARG_MESSAGE).orEmpty()
        return MaterialAlertDialogBuilder(requireContext())
            .setTitle(title)
            .setMessage(message)
            .setPositiveButton(R.string.error_dialog_ok, null)
            .create()
    }

    override fun onDismiss(dialog: DialogInterface) {
        super.onDismiss(dialog)
        parentFragmentManager.setFragmentResult(REQUEST_KEY, bundleOf())
    }

    companion object {
        const val TAG = "ErrorDialogFragment"
        const val REQUEST_KEY = "ErrorDialogFragment.request"

        private const val ARG_TITLE = "title"
        private const val ARG_MESSAGE = "message"

        fun newInstance(title: String, message: String): ErrorDialogFragment =
            ErrorDialogFragment().apply {
                arguments = bundleOf(
                    ARG_TITLE to title,
                    ARG_MESSAGE to message,
                )
            }
    }
}
