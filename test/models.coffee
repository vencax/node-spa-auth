
module.exports = (sequelize, DataTypes) ->

  User = sequelize.define 'user',
    username:
      type: DataTypes.STRING
      allowNull: false
      unique: true
    name: DataTypes.STRING
    email: DataTypes.STRING
    password: DataTypes.STRING
    gid:
      type: DataTypes.INTEGER
      allowNull: false
      defaultValue: 0 # 0-admins
    status:
      type: DataTypes.ENUM('enabled', 'disabled')
      defaultValue: 'enabled'
  ,
    tableName: "users"
