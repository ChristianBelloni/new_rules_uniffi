package com.example.trivial

import org.junit.Assert.assertEquals
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import com.mypackage.example.trivial.add;


@RunWith(RobolectricTestRunner::class)
class TrivialTests {
  @Test
  fun clickingButton_shouldChangeMessage() {
    val res = add(4u, 5u)
    val expected: ULong = 9u
    assertEquals(res, expected)
  }
}
