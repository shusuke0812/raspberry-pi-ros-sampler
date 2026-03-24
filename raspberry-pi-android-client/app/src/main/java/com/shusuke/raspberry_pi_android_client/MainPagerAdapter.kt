package com.shusuke.raspberry_pi_android_client

import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentActivity
import androidx.viewpager2.adapter.FragmentStateAdapter
import com.shusuke.raspberry_pi_android_client.presentation.connection.ConnectionFragment
import com.shusuke.raspberry_pi_android_client.presentation.service.CallServiceFragment
import com.shusuke.raspberry_pi_android_client.presentation.topic.TopicMonitorFragment

class MainPagerAdapter(activity: FragmentActivity) : FragmentStateAdapter(activity) {

    override fun getItemCount(): Int = TAB_COUNT

    override fun createFragment(position: Int): Fragment = when (position) {
        0 -> ConnectionFragment()
        1 -> TopicMonitorFragment()
        2 -> CallServiceFragment()
        else -> throw IllegalArgumentException("Invalid tab position: $position")
    }

    companion object {
        const val TAB_COUNT = 3
    }
}
