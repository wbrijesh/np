#!/bin/bash

function project_name() {
  name=$(enquirer input -m "Name of the project" -d "project_name")
}

function go_to_project() {
  if [[ "$location" == "Archives" ]]; then
    cd /Users/brijesh/Developer/archives
  elif [[ "$location" == "Learning" ]]; then
    cd /Users/brijesh/Developer/learning
  elif [[ "$location" == "Projects" ]]; then
    cd /Users/brijesh/Developer/projects
  elif [[ "$location" == "Scripts" ]]; then
    cd /Users/brijesh/Developer/scripts
  elif [[ "$location" == "Websites" ]]; then
    cd /Users/brijesh/Developer/websites
  else
    echo "Invalid project type a"
  fi
}


function project_location() {
  location=$(enquirer select -m "Select a location" -c "Archives" "Learning" "Projects" "Scripts" "Websites")

  go_to_project
}

function project_license() {
  license=$(enquirer select -m "Select a license type" -c "None" "Proprietary" "BSD" "GNU General Public")

  # add_license
}


function verify_availability() {
  if [[ "$location" == "Archives" ]]; then
    path="/Users/brijesh/Developer/archives/$name"
  elif [[ "$location" == "Learning" ]]; then
    path="/Users/brijesh/Developer/learning/$name"
  elif [[ "$location" == "Projects" ]]; then
    path="/Users/brijesh/Developer/projects/$name"
  elif [[ "$location" == "Scripts" ]]; then
    path="/Users/brijesh/Developer/scripts/$name"
  elif [[ "$location" == "Websites" ]]; then
    path="/Users/brijesh/Developer/websites/$name"
  else
    echo "Invalid project type"
  fi

  if [ -d $path ]; then
    echo "A directory with same name already exists" && exit
  fi
}

function initiate_git_repo() {
  git_confirm=$(enquirer confirm -m "Initiate a git repository?" -d)

  if [ "$git_confirm" = "true" ]; then
    echo "Initiating Git repository"
    cd $name
    git init
    cd ../
  fi

  git_private=$(enquirer confirm -m "Is this repository private?" -d)

  if [ "$git_private" = "true" ]; then
    echo "Creating private remote copy of repository"
    cd $name
    git add .
    git commit -S -m 'initial commit'
    git branch -M main
    gh repo create $name --private --source=. --remote=github
    git push github main
    cd ../
  else
    echo "Creating public remote copy of repository"
    cd $name
    git add .
    git commit -S -m 'initial commit'
    git branch -M main
    gh repo create $name --public --source=. --remote=github
    git push github main
    cd ../
  fi
}

function create_rust_project() {
  echo "Creating new Rust project"
  cargo new $name
}

function create_starter_project() {
  echo "Creating new Starter project"
  git clone https://github.com/wbrijesh/starter $name
  cd $name
  rm -rf .git
  cd ../
}


function create_go_project() {
  echo "Creating new Go project"
  mkdir $name
  cd $name
  go mod init github.com/wbrijesh/$name
  touch main.go
  cd ../
}

function create_nextjs_project() {
  echo "Creating new Next.js project"
  pnpm create next-app@latest $name --ts --eslint --tailwind --no-src-dir --app --import-alias '@/*'
}

function create_shell_script_project() {
  echo "Creating new Shell Script"
  mkdir $name
  cd $name
  touch $name.sh
  chmod +x $name.sh
  cd ../
}

function create_empty_project() {
  echo "Creating new Empty Script"
  mkdir $name
  cd $name
  touch README.md
  cd ../
}


function project_type() {
  project_type=$(enquirer select -m "Type of project" -c "Start from scratch" "Plain Rust binary target" "Fullstack Starter" "Plain Go binary target" "Plain Next.js with app router" "Shell script")

  if [[ "$project_type" == "Plain Rust binary target" ]]; then
    create_rust_project
  elif [[ "$project_type" == "Fullstack Starter" ]]; then
    create_starter_project
  elif [[ "$project_type" == "Plain Go binary target" ]]; then
    create_go_project
  elif [[ "$project_type" == "Plain Next.js with app router" ]]; then
    create_nextjs_project
  elif [[ "$project_type" == "Shell script" ]]; then
    create_shell_script_project
  elif [[ "$project_type" == "Start from scratch" ]]; then
    create_empty_project
  else
    echo "Invalid project type"
  fi
}

function start_tmux_session() {
  open "https://github.com/wbrijesh/$name"
  cd $name
  
  if [[ "$project_type" == "Plain Rust binary target" ]]; then
    tmux new-session -s $name \; send-keys 'nvim .' C-m \; new-window \; send-keys 'cargo run' C-m \; attach-session
  elif [[ "$project_type" == "Fullstack Starter" ]]; then
    tmux new-session -s $name \; send-keys 'nvim .' C-m \; new-window \; send-keys 'echo "Manually build and run docker containers if you would like to"' C-m \; attach-session
  elif [[ "$project_type" == "Plain Go binary target" ]]; then
    tmux new-session -s $name \; send-keys 'nvim .' C-m \; new-window \; send-keys 'go run main.go' C-m \; attach-session
  elif [[ "$project_type" == "Next.js" ]]; then
    tmux new-session -s $name \; send-keys 'nvim .' C-m \; new-window \; send-keys 'pnpm run dev' C-m \; attach-session
  elif [[ "$project_type" == "Shell script" ]]; then
    tmux new-session -s $name \; send-keys 'nvim .' C-m \; new-window \; send-keys "sh $name.sh" C-m \; attach-session
  elif [[ "$project_type" == "Start from scratch" ]]; then
    tmux new-session -s $name \; send-keys 'nvim .' C-m \; new-window \; send-keys "echo 'Start building project from scratch here'" C-m \; attach-session
  else
    echo "Invalid project type"
  fi
}


function main() {
  project_name
  
  project_location
  
  verify_availability

  project_type

  # project_license

  initiate_git_repo
  
  go_to_project

  start_tmux_session
}

main
