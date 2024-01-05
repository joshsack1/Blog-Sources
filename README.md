Before running this code it is important to note two things:
- I am using [julia](https://julialang.org) v.1.10.0
- I have set up an environment variable called `FRED_API_KEY` in my zshrc. Without doing the same, you will not be able to run the code in this repository

## How to Set up an Environment Variable

I don't know how to do this on windows, but on mac or linux you have to enter the following commands in your terminal:

To navigate to your home directory, `cd ~`

To edit your zsh configuration file, `vim .zshrc`

This will open vim. Use the `G` key to get to the bottom of the file. Then use the `o` key to start typing on a new line and add 
```zsh
export FRED_API_KEY = "whatever_you_get_from_fred"
```
Use the esc key to exit insert mode.
Type `:wq` to save your file and exit vim.
Then use `source .zshrc` to reevaluate your configuration file.

Test that you have done this correctly with `echo FRED_API_KEY`. It should output your api key
