mod cli;

fn main() {
    // println!("{}", std::env::current_dir().unwrap().display());
    cli::run_main().unwrap();
}
