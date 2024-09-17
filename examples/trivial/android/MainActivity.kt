package examples.android.lib

import uniffi.trivial.add;
import androidx.appcompat.app.AlertDialog
import android.os.Bundle
import android.widget.Button
import android.widget.LinearLayout
import android.widget.LinearLayout.LayoutParams
import androidx.appcompat.app.AppCompatActivity


class MainActivity : AppCompatActivity() {

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    val parent = LinearLayout(this).apply {
      orientation = LinearLayout.VERTICAL
    }.also { it.addView(Button(this).apply { text = "Foo!" }) }
    setContentView(parent, LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT))
    AlertDialog.Builder(this)
      .setMessage("Blah blah blah? ")
      .show()
    add(4u, 5u)
    // Ensure Serialization plugin has run and generated code correctly.
    
  }
}
