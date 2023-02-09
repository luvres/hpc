NavConfig.categories_whitelist=true
NavConfig.categories=["Files", "Jobs", "Clusters", "Interactive Apps"]
#NavConfig.categories=["Apps","Files", "Jobs", "Clusters", "Interactive Apps", "Reports"]

OodFilesApp.candidate_favorite_paths.tap do |paths|
  # add scratch space directories
  paths << FavoritePath.new("/scratch/#{User.new.name}", title: "Scratch")
end
