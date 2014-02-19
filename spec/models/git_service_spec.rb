      expect(service).to receive(:checkout).with("master").and_return("Switched to branch 'master'\n")
      with_service do |git|
        expect(git.checkout("master")).to eq "Switched to branch 'master'"
      end
    expect(service).to receive(:log).and_return("log_message\n")

  it "#branches" do
    expect(service).to receive(:branch).and_return(<<-EOGIT)
* master
  branch1
  branch2
    EOGIT

    with_service do |git|
      expect(git.branches).to eq %w{master branch1 branch2}
    end
  end

  it "#current_branch" do
    expect(service).to receive(:rev_parse).and_return("master\n")

    with_service do |git|
      expect(git.current_branch).to eq "master"
    end
  end

  it "#diff_details" do
    expect(service).to receive(:diff).with("--patience", "-U0", "--no-color", "6c4a4487~..6c4a4487").and_return(<<-EOGIT)
diff --git a/new_file.rb b/new_file.rb
new file mode 100644
index 0000000..b4c1281
--- /dev/null
+++ b/new_file.rb
@@ -0,0 +1,39 @@
+class SomeClass
+end
+
diff --git a/changed_file.rb b/changed_file.rb
index 4f807bb..57e5993 100644
--- a/changed_file.rb
+++ b/changed_file.rb
@@ -29,0 +30 @@ def method1
+    x = 1
@@ -30,0 +32 @@ def method2
+    x = 2
@@ -68,3 +69,0 @@ def method 3
-    if x == 1
-      x = 3
-    end
    EOGIT

    with_service do |git|
      expect(git.diff_details("6c4a4487")).to eq(
        "new_file.rb"     => [1, 2, 3],
        "changed_file.rb" => [30, 32]
      )
    end
  end

  it ".pr_branch" do
    expect(described_class.pr_branch(133)).to eq "pr/133"
  end

  it "#pr_branch" do
    with_service do |git|
      expect(git.pr_branch(133)).to eq "pr/133"
    end
  end

  it ".pr_number" do
    expect(described_class.pr_number("pr/133")).to eq 133
  end

  it "#pr_number" do
    with_service do |git|
      expect(git.pr_number("pr/133")).to eq 133
    end
  end

  context ".pr_branch?" do
    it "with a pr branch" do
      expect(described_class.pr_branch?("pr/133")).to be_true
    end

    it "with a regular branch" do
      expect(described_class.pr_branch?("master")).to be_false
    end
  end

  context "#pr_branch?" do
    it "with pr branch" do
      with_service do |git|
        expect(git.pr_branch?("pr/133")).to be_true
      end
    end

    it "with regular branch" do
      with_service do |git|
        expect(git.pr_branch?("master")).to be_false
      end
    end

    it "with no branch and current branch is a pr branch" do
      described_class.any_instance.stub(:current_branch => "pr/133")
      with_service do |git|
        expect(git.pr_branch?).to be_true
      end
    end

    it "with no branch and current branch is a regular branch" do
      described_class.any_instance.stub(:current_branch => "master")
      with_service do |git|
        expect(git.pr_branch?).to be_false
      end
    end
  end

  context "#update_pr_branch" do
    it "with pr branch" do
      expect(service).to receive(:fetch).with("-fu", "upstream", "refs/pull/133/head:pr/133").and_return("\n")
      expect(service).to receive(:reset).with("--hard").and_return("\n")

      with_service { |git| git.update_pr_branch("pr/133") }
    end

    it "with no branch and on a pr branch" do
      described_class.any_instance.stub(:current_branch => "pr/133")
      expect(service).to receive(:fetch).with("-fu", "upstream", "refs/pull/133/head:pr/133").and_return("\n")
      expect(service).to receive(:reset).with("--hard").and_return("\n")

      with_service { |git| git.update_pr_branch }
    end
  end

  context "#create_pr_branch" do
    it "with pr branch" do
      expect(service).to receive(:fetch).with("-fu", "upstream", "refs/pull/133/head:pr/133").and_return("\n")
      expect(service).to receive(:reset).with("--hard").and_return("\n")

      with_service { |git| git.create_pr_branch("pr/133") }
    end
  end