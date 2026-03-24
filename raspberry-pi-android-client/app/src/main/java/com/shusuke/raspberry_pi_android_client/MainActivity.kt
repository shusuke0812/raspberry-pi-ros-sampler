package com.shusuke.raspberry_pi_android_client

import android.os.Bundle
import android.view.View
import androidx.activity.enableEdgeToEdge
import androidx.appcompat.app.AppCompatActivity
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsCompat
import androidx.core.view.updatePadding
import androidx.viewpager2.widget.ViewPager2
import com.google.android.material.bottomnavigation.BottomNavigationView

class MainActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContentView(R.layout.activity_main)

        val mainRoot = findViewById<View>(R.id.main_root)
        val bottomNav = findViewById<BottomNavigationView>(R.id.bottom_navigation)
        val viewPager = findViewById<ViewPager2>(R.id.view_pager)
        viewPager.adapter = MainPagerAdapter(this)

        ViewCompat.setOnApplyWindowInsetsListener(mainRoot) { v, insets ->
            val systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars())
            val cutout = insets.getInsets(WindowInsetsCompat.Type.displayCutout())
            v.updatePadding(
                left = maxOf(systemBars.left, cutout.left),
                top = maxOf(systemBars.top, cutout.top),
                right = maxOf(systemBars.right, cutout.right),
                bottom = 0,
            )
            insets
        }

        ViewCompat.setOnApplyWindowInsetsListener(bottomNav) { v, insets ->
            val bars = insets.getInsets(WindowInsetsCompat.Type.systemBars())
            v.setPadding(v.paddingLeft, v.paddingTop, v.paddingRight, bars.bottom)
            insets
        }

        bottomNav.setOnItemSelectedListener { item ->
            val targetPage = when (item.itemId) {
                R.id.nav_connection -> 0
                R.id.nav_topic -> 1
                R.id.nav_service -> 2
                else -> return@setOnItemSelectedListener false
            }
            if (viewPager.currentItem != targetPage) {
                viewPager.setCurrentItem(targetPage, true)
            }
            true
        }

        viewPager.registerOnPageChangeCallback(object : ViewPager2.OnPageChangeCallback() {
            override fun onPageSelected(position: Int) {
                val id = when (position) {
                    0 -> R.id.nav_connection
                    1 -> R.id.nav_topic
                    2 -> R.id.nav_service
                    else -> return
                }
                if (bottomNav.selectedItemId != id) {
                    bottomNav.selectedItemId = id
                }
            }
        })
    }
}
