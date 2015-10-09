
module.exports = (sequelize, DataTypes) ->

  User = sequelize.define 'user',
    uname:
      type: DataTypes.STRING
      allowNull: false
      unique: true
    name: DataTypes.STRING
    email: DataTypes.STRING
    passwd: DataTypes.STRING
    gid:
      type: DataTypes.INTEGER
      allowNull: false
      defaultValue: 0 # 0-admins
    state:
      type: DataTypes.INTEGER
      allowNull: false
      defaultValue: 0
  ,
    tableName: "users"
