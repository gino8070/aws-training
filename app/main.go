package main

import (
	"os"

	"github.com/gin-gonic/gin"
)

var router *gin.Engine
var defaultPort = "8080"

func main() {
	port := os.Getenv("GONIC_PORT")
	if port == "" {
		port = defaultPort
	}
	router = gin.Default()
	router.GET("/", GetRootRoute)
	router.Run(":" + port)
}

func GetRootRoute(c *gin.Context) {
	c.JSON(200, "Ok")
}
