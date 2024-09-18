package trivial;

import my_package.add;

class Main {
  companion object {
    @JvmStatic
    fun main(args: Array<String>) {
        println(add(5u, 4u))
    }
  }
}
