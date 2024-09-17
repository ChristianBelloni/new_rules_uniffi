package trivial;

import uniffi.trivial.add;

class Main {
  companion object {
    @JvmStatic
    fun main(args: Array<String>) {
        println(add(5u, 4u))
    }
  }
}
