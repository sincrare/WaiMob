if User.count == 0 
  User.create(email: "waimob@test.com", password: "aaaaaa", password_confirmation: "aaaaaa")
end

if Document.count == 0
  Document.create(title: "first document")
end