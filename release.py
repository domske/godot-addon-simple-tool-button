import os
import sys
import shutil
import subprocess

def run_command(command, check=True):
  result = subprocess.run(command, shell=True, text=True, capture_output=True)
  if check and result.returncode != 0:
    print(f"Error: {result.stderr}")
    exit(1)
  return result.stdout.strip()

def copy_addons_folder():
  addons_src = os.path.join('project', 'addons')
  addons_dst = 'addons'
  if os.path.exists(addons_dst):
    shutil.rmtree(addons_dst)
  shutil.copytree(addons_src, addons_dst)

def update_release_branch(version):
  copy_addons_folder()
  run_command('git add addons')
  run_command('git stash', check=False)

  branch_exist = run_command('git branch --list release', check=False)
  if not branch_exist:
    run_command('git checkout --orphan release')
  else:
    run_command('git checkout release')

  run_command('git reset --hard')
  run_command('git stash pop', check=False)
  run_command('git add addons')
  run_command(f'git commit -m "Release {version}"')
  run_command(f'git tag {version}')
  run_command('git push origin release')
  run_command(f'git push origin {version}')
  run_command('git checkout main')
  run_command('git reset --hard')

  print(f"Release branch updated with {version}.")

def get_last_n_tags(n):
  command = "git tag --sort=-v:refname"
  tags = run_command(command).split('\n')
  tags = [tag for tag in tags if tag]
  last_n_tags = tags[:n]
  return last_n_tags

def is_git_clean():
  status = run_command('git status --porcelain')
  return status == ''

if __name__ == "__main__":
  if not is_git_clean():
    print("Git repo is not clean. Make your commits first!")
    sys.exit(1)
  try:
    last_tags = get_last_n_tags(5)
    if last_tags: print(f"The last few tags are: {last_tags}")
    version = input("Enter release version (e.g., v1.0.0): ")
  except KeyboardInterrupt:
    print("\nAborted")
    sys.exit(1)

  update_release_branch(version)
