package com.greenharbor.Green.Harbor.Backend.config;

import org.springframework.beans.factory.annotation.Configurable;
import org.springframework.stereotype.Component;


public class AppConstantConfig {

    public static String EMAIL_IS_EXIST = "User with this email is exist..";
    public static String ERROR_TO_LOGIN = "Coming error when trying to login";
    public static String EMAIL = "email";
    public static String TOKEN = "token";
    public static String ROLE = "role";
    public static String SESSION = "session:";
    public static String USER_NOT_FOUND = "User not found :(";
    public static String INVALID_PASSWORD = "Invalid password";
    public static String BEARER = "Bearer ";
    public static String MESSAGE = "Message";
    public static String LOGOUT_SUCCESSFUL = "Logout successful. Token discarded on client.";
}
